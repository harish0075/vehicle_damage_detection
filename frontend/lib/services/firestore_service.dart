import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Save a damage detection to Firestore
  Future<String?> saveDamageDetection({
    required List<Map<String, dynamic>> damages,
    required String? imagePath,
    required double imageWidth,
    required double imageHeight,
  }) async {
    // Check if user is logged in
    if (_uid == null) {
      throw Exception('User not logged in. Please sign in to save detections.');
    }

    print('📝 Saving detection to Firestore...');
    print('   User ID: $_uid');
    print('   Damages: ${damages.length}');
    print('   Image path: $imagePath');

    try {
      final docRef = await _db
          .collection('users')
          .doc(_uid)
          .collection('detections')
          .add({
        'damages': damages,
        'imagePath': imagePath,
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Detection saved successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving detection to Firestore: $e');
      rethrow; // Rethrow instead of returning null
    }
  }

  /// Load all damage detections for the current user
  Stream<List<Map<String, dynamic>>> loadDamageDetections() {
    if (_uid == null) {
      print('⚠️  No user logged in, returning empty stream');
      return Stream.value([]);
    }

    print('📖 Loading detections for user: $_uid');

    return _db
        .collection('users')
        .doc(_uid)
        .collection('detections')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('📦 Loaded ${snapshot.docs.length} detections from Firestore');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Convert Firestore Timestamp to ISO string
        if (data['createdAt'] != null) {
          data['timestamp'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
    });
  }

  /// Delete a specific detection
  Future<void> deleteDetection(String detectionId) async {
    if (_uid == null) {
      throw Exception('User not logged in');
    }

    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('detections')
          .doc(detectionId)
          .delete();
      print('🗑️  Deleted detection: $detectionId');
    } catch (e) {
      print('❌ Error deleting detection: $e');
      rethrow;
    }
  }
}
