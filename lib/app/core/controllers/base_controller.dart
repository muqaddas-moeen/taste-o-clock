import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

/// Shared controller utilities for consistent loading and error handling.
abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<T?> runGuarded<T>(
    Future<Result<T>> Function() action, {
    bool showErrorSnackbar = true,
  }) async {
    if (isLoading.value) return null;

    isLoading.value = true;
    try {
      final result = await action();
      return result.when(
        onSuccess: (data) => data,
        onFailure: (failure) {
          if (showErrorSnackbar) {
            Helpers.showError(failure.message);
          }
          return null;
        },
      );
    } catch (_) {
      if (showErrorSnackbar) {
        Helpers.showError('Something went wrong. Please try again.');
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void handleFailure(AppFailure failure, {bool showSnackbar = true}) {
    if (showSnackbar) {
      Helpers.showError(failure.message);
    }
  }
}
