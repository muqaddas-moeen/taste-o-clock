import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/config/firebase_collections.dart';
import 'package:taste_o_clock/app/core/errors/app_exception.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/user_location_model.dart';
import 'package:taste_o_clock/app/data/models/user_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';
import 'package:taste_o_clock/app/data/repositories/user_repository.dart';
import 'package:taste_o_clock/app/data/services/firebase_service.dart';
import 'package:taste_o_clock/app/data/services/location_service.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required FirebaseService firebaseService,
    required LocationService locationService,
  })  : _firebaseService = firebaseService,
        _locationService = locationService;

  final FirebaseService _firebaseService;
  final LocationService _locationService;

  @override
  Future<Result<UserModel>> syncCurrentLocation({required String userId}) async {
    if (userId.isEmpty) {
      return const Error(
        AppFailure(code: 'missing_user', message: 'User not signed in.'),
      );
    }

    try {
      final location = await _locationService.getCurrentLocation();
      return updateLocation(userId: userId, location: location);
    } on AppException catch (e) {
      return Error(e.toFailure());
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'location_error',
          message: 'Unable to fetch your current location.',
        ),
      );
    }
  }

  @override
  Future<Result<UserModel>> updateLocation({
    required String userId,
    required UserLocationModel location,
  }) async {
    return _patchUser(
      userId: userId,
      patch: {
        UserFields.location: location.copyWith(updatedAt: DateTime.now()).toMap(),
      },
    );
  }

  @override
  Future<Result<UserModel>> updatePaymentInfo({
    required String userId,
    required UserPaymentInfoModel paymentInfo,
  }) async {
    return _patchUser(
      userId: userId,
      patch: {
        UserFields.paymentInfo:
            paymentInfo.copyWith(updatedAt: DateTime.now()).toMap(),
      },
    );
  }

  @override
  Future<Result<UserModel>> updateBasicDetails({
    required String userId,
    String? phone,
  }) async {
    return _patchUser(
      userId: userId,
      patch: {UserFields.phone: phone?.trim()},
    );
  }

  @override
  Future<Result<void>> syncFcmToken({
    required String userId,
    required String token,
  }) async {
    if (userId.isEmpty || token.trim().isEmpty) {
      return const Error(
        AppFailure(code: 'invalid_token', message: 'Unable to sync push token.'),
      );
    }

    try {
      await _firebaseService.userDocument(userId).set(
        {
          NotificationFields.fcmToken: token.trim(),
          NotificationFields.fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
          FirebaseFields.updatedAt: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return const Success(null);
    } on FirebaseException catch (e) {
      return Error(
        AppFailure(
          code: e.code,
          message: e.message ?? 'Unable to sync push token.',
        ),
      );
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'fcm_token_error',
          message: 'Unable to sync push token.',
        ),
      );
    }
  }

  Future<Result<UserModel>> _patchUser({
    required String userId,
    required Map<String, dynamic> patch,
  }) async {
    if (userId.isEmpty) {
      return const Error(
        AppFailure(code: 'missing_user', message: 'User not signed in.'),
      );
    }

    try {
      final userRef = _firebaseService.userDocument(userId);
      final doc = await userRef.get();

      if (!doc.exists) {
        return const Error(
          AppFailure(code: 'user_not_found', message: 'Profile not found.'),
        );
      }

      await userRef.set(
        {
          ...patch,
          FirebaseFields.updatedAt: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final updatedDoc = await userRef.get();
      return Success(UserModel.fromFirestore(updatedDoc));
    } on FirebaseException catch (e) {
      return Error(
        AppFailure(
          code: e.code,
          message: e.message ?? 'Unable to update profile.',
        ),
      );
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'profile_update_error',
          message: 'Unable to update profile.',
        ),
      );
    }
  }
}
