import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:taste_o_clock/app/core/config/firebase_collections.dart';

import 'package:taste_o_clock/app/data/models/user_location_model.dart';

import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';



class UserModel {

  const UserModel({

    required this.id,

    required this.email,

    this.displayName,

    this.photoUrl,

    this.phone,

    this.authProvider = 'google',

    this.location,

    this.paymentInfo,

    required this.createdAt,

    required this.updatedAt,

    this.lastLoginAt,

  });



  final String id;

  final String email;

  final String? displayName;

  final String? photoUrl;

  final String? phone;

  final String authProvider;

  final UserLocationModel? location;

  final UserPaymentInfoModel? paymentInfo;

  final DateTime createdAt;

  final DateTime updatedAt;

  final DateTime? lastLoginAt;



  String get initials {

    final name = displayName?.trim();

    if (name == null || name.isEmpty) {

      return email.isNotEmpty ? email[0].toUpperCase() : '?';

    }



    final parts = name.split(RegExp(r'\s+'));

    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();

  }



  bool get hasDeliveryLocation {
    final value = location;
    if (value == null) return false;

    return value.hasCoordinates ||
        (value.addressLine?.trim().isNotEmpty ?? false) ||
        (value.city?.trim().isNotEmpty ?? false);
  }



  bool get hasPaymentInfo =>

      paymentInfo != null && paymentInfo!.isComplete;



  factory UserModel.fromFirebaseUser(

    User user, {

    DateTime? createdAt,

    DateTime? lastLoginAt,

    UserLocationModel? location,

    UserPaymentInfoModel? paymentInfo,

    String? phone,

  }) {

    final now = DateTime.now();

    return UserModel(

      id: user.uid,

      email: user.email ?? '',

      displayName: user.displayName,

      photoUrl: user.photoURL,

      phone: phone,

      authProvider: 'google',

      location: location,

      paymentInfo: paymentInfo,

      createdAt: createdAt ?? now,

      updatedAt: now,

      lastLoginAt: lastLoginAt ?? now,

    );

  }



  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {

    final data = doc.data() ?? {};

    return UserModel(

      id: doc.id,

      email: data[FirebaseFields.email] as String? ?? '',

      displayName: data[FirebaseFields.displayName] as String?,

      photoUrl: data[FirebaseFields.photoUrl] as String?,

      phone: data[UserFields.phone] as String?,

      authProvider: data[FirebaseFields.authProvider] as String? ?? 'google',

      location: UserLocationModel.fromMap(

        data[UserFields.location] as Map<String, dynamic>?,

      ),

      paymentInfo: UserPaymentInfoModel.fromMap(

        data[UserFields.paymentInfo] as Map<String, dynamic>?,

      ),

      createdAt:

          _parseTimestamp(data[FirebaseFields.createdAt]) ?? DateTime.now(),

      updatedAt:

          _parseTimestamp(data[FirebaseFields.updatedAt]) ?? DateTime.now(),

      lastLoginAt: _parseTimestamp(data[FirebaseFields.lastLoginAt]),

    );

  }



  Map<String, dynamic> toFirestore({required bool isNewUser}) {

    final now = Timestamp.now();

    return {

      FirebaseFields.email: email,

      FirebaseFields.displayName: displayName,

      FirebaseFields.photoUrl: photoUrl,

      UserFields.phone: phone,

      FirebaseFields.authProvider: authProvider,

      UserFields.location: location?.toMap(),

      UserFields.paymentInfo: paymentInfo?.toMap(),

      FirebaseFields.createdAt:

          isNewUser ? now : Timestamp.fromDate(createdAt),

      FirebaseFields.updatedAt: now,

      FirebaseFields.lastLoginAt: Timestamp.fromDate(lastLoginAt ?? DateTime.now()),

    };

  }



  UserModel copyWith({

    String? email,

    String? displayName,

    String? photoUrl,

    String? phone,

    UserLocationModel? location,

    UserPaymentInfoModel? paymentInfo,

    DateTime? updatedAt,

    DateTime? lastLoginAt,

  }) {

    return UserModel(

      id: id,

      email: email ?? this.email,

      displayName: displayName ?? this.displayName,

      photoUrl: photoUrl ?? this.photoUrl,

      phone: phone ?? this.phone,

      authProvider: authProvider,

      location: location ?? this.location,

      paymentInfo: paymentInfo ?? this.paymentInfo,

      createdAt: createdAt,

      updatedAt: updatedAt ?? this.updatedAt,

      lastLoginAt: lastLoginAt ?? this.lastLoginAt,

    );

  }



  static DateTime? _parseTimestamp(Object? value) {

    if (value is Timestamp) return value.toDate();

    if (value is DateTime) return value;

    return null;

  }

}


