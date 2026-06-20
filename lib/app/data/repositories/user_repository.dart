import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/user_location_model.dart';
import 'package:taste_o_clock/app/data/models/user_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';

abstract class UserRepository {
  Future<Result<UserModel>> syncCurrentLocation({required String userId});

  Future<Result<UserModel>> updateLocation({
    required String userId,
    required UserLocationModel location,
  });

  Future<Result<UserModel>> updatePaymentInfo({
    required String userId,
    required UserPaymentInfoModel paymentInfo,
  });

  Future<Result<UserModel>> updateBasicDetails({
    required String userId,
    String? phone,
  });

  Future<Result<void>> syncFcmToken({
    required String userId,
    required String token,
  });
}
