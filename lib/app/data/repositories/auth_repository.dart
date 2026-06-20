import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/user_model.dart';

abstract class AuthRepository {
  UserModel? get currentUser;

  Stream<UserModel?> get authStateChanges;

  Future<Result<UserModel>> signInWithGoogle();

  Future<Result<void>> signOut();

  Future<Result<UserModel?>> syncCurrentUser();

  Future<Result<bool>> validateFirebaseConnection();
}
