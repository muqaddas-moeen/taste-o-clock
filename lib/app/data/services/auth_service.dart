import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taste_o_clock/app/core/config/app_config.dart';
import 'package:taste_o_clock/app/core/errors/app_exception.dart';
import 'package:taste_o_clock/app/core/utils/auth_failure_mapper.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
              serverClientId: AppConfig.googleWebClientId,
            );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AppException(
          code: 'sign_in_cancelled',
          message: AuthFailureMapper.fromCode('sign_in_cancelled').message,
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw AppException(
          code: 'invalid-credential',
          message: AuthFailureMapper.fromCode('invalid-credential').message,
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AppException(
        code: e.code,
        message: AuthFailureMapper.fromCode(e.code, fallbackMessage: e.message)
            .message,
        cause: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        code: 'auth_error',
        message: AuthFailureMapper.fromCode('auth_error').message,
        cause: e,
      );
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
