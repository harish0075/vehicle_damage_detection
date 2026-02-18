import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  /// Save full claim (damage + policy + bill)
  Future<void> saveClaim({
    required Map<String, dynamic> damages,
    required Map<String, dynamic> policy,
    required Map<String, dynamic> bill,
  }) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('claims')
        .add({
      'damages': damages,
      'policy': policy,
      'bill': bill,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch user claim history
  Stream<QuerySnapshot> getClaimsStream() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('claims')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
