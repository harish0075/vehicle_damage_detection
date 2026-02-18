import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 Recommended: explicit scopes for Firebase + profile/email
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  /// Current logged-in Firebase user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream (used by AuthWrapper)
  Stream<User?> get authState => _auth.authStateChanges();

  /// 🔥 Google Sign-In (Production Safe)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Try silent sign-in first (better UX)
      GoogleSignInAccount? googleUser =
          await _googleSignIn.signInSilently();

      // If no previous session, open account picker
      googleUser ??= await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled login
        throw Exception('Google Sign-In cancelled by user');
      }

      // Get Google auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'NO_ID_TOKEN',
          message: 'Missing Google ID Token. Please ensure Google Sign-In is configured in Firebase Console.',
        );
      }

      // Create Firebase credential
      final AuthCredential credential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase (this creates the Firebase user)
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Google Sign-In error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// 🔥 Anonymous Sign-In (Fallback option)
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      throw Exception('Anonymous sign-in failed: $e');
    }
  }

  /// 🔥 Proper logout (important for switching accounts)
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect(); // fully clears session
      await _auth.signOut();
    } catch (e) {
      // Even if Google Sign-In fails, still sign out from Firebase
      await _auth.signOut();
      print('Logout warning: $e');
    }
  }
}

