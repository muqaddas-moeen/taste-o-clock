import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  DocumentReference<Map<String, dynamic>> userDocument(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  /// Lightweight connectivity check. Must not block app startup.
  Future<bool> validateConnection() async {
    return Firebase.apps.isNotEmpty;
  }
}
