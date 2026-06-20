import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taste_o_clock/app/core/config/hive_boxes.dart';
import 'package:taste_o_clock/app/core/errors/app_exception.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/core/utils/auth_failure_mapper.dart';
import 'package:taste_o_clock/app/data/models/user_model.dart';
import 'package:taste_o_clock/app/data/repositories/auth_repository.dart';
import 'package:taste_o_clock/app/data/services/auth_service.dart';
import 'package:taste_o_clock/app/data/services/firebase_service.dart';
import 'package:taste_o_clock/app/data/services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthService authService,
    required FirebaseService firebaseService,
    required StorageService storageService,
  })  : _authService = authService,
        _firebaseService = firebaseService,
        _storageService = storageService;

  final AuthService _authService;
  final FirebaseService _firebaseService;
  final StorageService _storageService;

  UserModel? _cachedUser;

  @override
  UserModel? get currentUser => _cachedUser;

  @override
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.asyncMap(_mapFirebaseUser);
  }

  @override
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return Error(
          AuthFailureMapper.fromCode('missing_user'),
        );
      }

      final user = await _upsertUser(firebaseUser, updateLastLogin: true);
      _cachedUser = user;
      await _persistSession(user.id);
      return Success(user);
    } on AppException catch (e) {
      return Error(e.toFailure());
    } on FirebaseException catch (e) {
      return Error(
        AuthFailureMapper.fromCode(
          e.code,
          fallbackMessage: e.message,
        ),
      );
    } catch (_) {
      return Error(AuthFailureMapper.fromCode('auth_error'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authService.signOut();
      _cachedUser = null;
      await _clearSessionCache();
      return const Success(null);
    } on AppException catch (e) {
      return Error(e.toFailure());
    } catch (_) {
      return Error(AuthFailureMapper.fromCode('sign_out_error'));
    }
  }

  @override
  Future<Result<UserModel?>> syncCurrentUser() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        _cachedUser = null;
        await _clearSessionCache();
        return const Success(null);
      }

      try {
        _cachedUser = await _resolveUser(firebaseUser).timeout(
          const Duration(seconds: 5),
        );
      } on TimeoutException {
        _cachedUser = UserModel.fromFirebaseUser(firebaseUser);
      } catch (_) {
        _cachedUser = UserModel.fromFirebaseUser(firebaseUser);
      }

      await _persistSession(_cachedUser!.id);
      return Success(_cachedUser);
    } on FirebaseException catch (e) {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        _cachedUser = UserModel.fromFirebaseUser(firebaseUser);
        await _persistSession(_cachedUser!.id);
        return Success(_cachedUser);
      }
      return Error(
        AuthFailureMapper.fromCode(
          e.code,
          fallbackMessage: e.message,
        ),
      );
    } catch (_) {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        _cachedUser = UserModel.fromFirebaseUser(firebaseUser);
        await _persistSession(_cachedUser!.id);
        return Success(_cachedUser);
      }
      return Error(AuthFailureMapper.fromCode('sync_error'));
    }
  }

  @override
  Future<Result<bool>> validateFirebaseConnection() async {
    try {
      await _firebaseService.validateConnection();
      return const Success(true);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'firebase_unreachable',
          message: 'Unable to reach Firebase. Check your connection.',
        ),
      );
    }
  }

  Future<UserModel?> _mapFirebaseUser(User? firebaseUser) async {
    if (firebaseUser == null) {
      _cachedUser = null;
      await _clearSessionCache();
      return null;
    }

    _cachedUser = await _resolveUser(firebaseUser);
    await _persistSession(_cachedUser!.id);
    return _cachedUser;
  }

  Future<UserModel> _resolveUser(User firebaseUser) async {
    final doc = await _firebaseService.userDocument(firebaseUser.uid).get();

    if (doc.exists) {
      final storedUser = UserModel.fromFirestore(doc);
      final refreshedProfile = storedUser.copyWith(
        displayName: firebaseUser.displayName ?? storedUser.displayName,
        photoUrl: firebaseUser.photoURL ?? storedUser.photoUrl,
        email: firebaseUser.email ?? storedUser.email,
      );

      if (_hasProfileChanges(storedUser, refreshedProfile)) {
        return _upsertUser(
          firebaseUser,
          existing: storedUser,
          updateLastLogin: false,
        );
      }

      return refreshedProfile;
    }

    return _upsertUser(firebaseUser, updateLastLogin: false);
  }

  Future<UserModel> _upsertUser(
    User firebaseUser, {
    UserModel? existing,
    bool updateLastLogin = true,
  }) async {
    final userRef = _firebaseService.userDocument(firebaseUser.uid);
    UserModel? existingDoc = existing;

    if (existingDoc == null) {
      final doc = await userRef.get();
      if (doc.exists) {
        existingDoc = UserModel.fromFirestore(doc);
      }
    }

    final user = UserModel.fromFirebaseUser(
      firebaseUser,
      createdAt: existingDoc?.createdAt,
      lastLoginAt: updateLastLogin ? DateTime.now() : existingDoc?.lastLoginAt,
      location: existingDoc?.location,
      paymentInfo: existingDoc?.paymentInfo,
      phone: existingDoc?.phone,
    );

    await userRef.set(
      user.toFirestore(isNewUser: existingDoc == null),
      SetOptions(merge: true),
    );

    return user;
  }

  bool _hasProfileChanges(UserModel stored, UserModel refreshed) {
    return stored.displayName != refreshed.displayName ||
        stored.photoUrl != refreshed.photoUrl ||
        stored.email != refreshed.email;
  }

  Future<void> _persistSession(String userId) async {
    await _storageService.sessionBox.put(HiveKeys.currentUserId, userId);
  }

  Future<void> _clearSessionCache() async {
    if (_storageService.sessionBox.containsKey(HiveKeys.currentUserId)) {
      await _storageService.sessionBox.delete(HiveKeys.currentUserId);
    }
  }
}
