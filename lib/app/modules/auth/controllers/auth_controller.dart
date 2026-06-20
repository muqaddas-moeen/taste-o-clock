import 'dart:async';

import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/controllers/base_controller.dart';
import 'package:taste_o_clock/app/core/enums/auth_status.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/user_model.dart';
import 'package:taste_o_clock/app/data/repositories/auth_repository.dart';
import 'package:taste_o_clock/app/data/repositories/user_repository.dart';
import 'package:taste_o_clock/app/data/services/local_notification_service.dart';
import 'package:taste_o_clock/app/modules/main_shell/main_shell_tab_controllers.dart';
import 'package:taste_o_clock/app/modules/notification/controllers/notification_controller.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class AuthController extends BaseController {
  AuthController({
    AuthRepository? authRepository,
    UserRepository? userRepository,
  })  : _authRepository = authRepository ?? Get.find<AuthRepository>(),
        _userRepository = userRepository ?? Get.find<UserRepository>();

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  final Rxn<UserModel> user = Rxn<UserModel>();
  final Rx<AuthStatus> authStatus = AuthStatus.initial.obs;
  final RxBool isFirebaseReady = false.obs;
  final RxBool isSessionReady = false.obs;

  StreamSubscription<UserModel?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> initializeSession() async {
    authStatus.value = AuthStatus.initial;

    try {
      final syncResult = await _authRepository.syncCurrentUser();
      syncResult.when(
        onSuccess: (syncedUser) {
          user.value = syncedUser;
          authStatus.value = syncedUser != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated;
          if (syncedUser != null) {
            _syncProfileLocationIfNeeded(syncedUser);
          }
        },
        onFailure: (_) {
          user.value = null;
          authStatus.value = AuthStatus.unauthenticated;
        },
      );
    } catch (_) {
      user.value = null;
      authStatus.value = AuthStatus.unauthenticated;
    } finally {
      isSessionReady.value = true;
    }

    final connectionResult = await _authRepository.validateFirebaseConnection();
    isFirebaseReady.value = connectionResult.isSuccess;
  }

  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final result = await _authRepository.signInWithGoogle();
      switch (result) {
        case Success(:final data):
          user.value = data;
          authStatus.value = AuthStatus.authenticated;
          Helpers.showSuccess(
            'Welcome, ${data.displayName ?? 'Guest'}!',
          );
          _syncProfileLocation(data.id);
          if (Get.isRegistered<OrderController>()) {
            Get.find<OrderController>().bootstrapAfterLogin();
          }
          await LocalNotificationService.instance.ensureNotificationsEnabled();
          Get.offAllNamed(AppRoutes.productList);
        case Error(:final failure):
          if (failure.code != 'sign_in_cancelled') {
            handleFailure(failure);
          }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final result = await _authRepository.signOut();
      result.when(
        onSuccess: (_) async {
          final userId = user.value?.id;
          if (userId != null && Get.isRegistered<NotificationController>()) {
            await Get.find<NotificationController>()
                .clearPersistedOnSignOut(userId);
          }
          user.value = null;
          authStatus.value = AuthStatus.unauthenticated;
          MainShellTabControllers.dispose();
          Get.offAllNamed(AppRoutes.login);
        },
        onFailure: handleFailure,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool get isAuthenticated =>
      authStatus.value == AuthStatus.authenticated && user.value != null;

  Future<void> _syncProfileLocationIfNeeded(UserModel currentUser) async {
    if (currentUser.hasDeliveryLocation) return;
    await _syncProfileLocation(currentUser.id);
  }

  Future<void> _syncProfileLocation(String userId) async {
    final result = await _userRepository.syncCurrentLocation(userId: userId);
    result.when(
      onSuccess: (updatedUser) => user.value = updatedUser,
      onFailure: (_) {},
    );
  }

  void _listenToAuthChanges() {
    _authSubscription = _authRepository.authStateChanges.listen(
      (sessionUser) {
        user.value = sessionUser;
        authStatus.value = sessionUser != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;

        if (isSessionReady.value &&
            sessionUser == null &&
            Get.currentRoute != AppRoutes.login &&
            Get.currentRoute != AppRoutes.splash) {
          MainShellTabControllers.dispose();
          Get.offAllNamed(AppRoutes.login);
        }
      },
    );
  }
}
