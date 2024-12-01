import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppAuthenticationService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file', // For specific files created by the app
      // Or use 'https://www.googleapis.com/auth/drive.appdata' // For application-specific folder
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> checkGooglePlayServices() async {
    GooglePlayServicesAvailability availability;
    try {
      availability = await GoogleApiAvailability.instance
          .checkGooglePlayServicesAvailability();
    } catch (e) {
      print('Error checking Google Play Services: $e');
      return false;
    }
    return availability == GooglePlayServicesAvailability.success;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Check Google Play Services first
      final hasGooglePlayServices = await checkGooglePlayServices();
      if (!hasGooglePlayServices && !kIsWeb) {
        throw Exception('Google Play Services not available');
      }

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Get auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Save user info to secure storage
      const storage = FlutterSecureStorage();
      await storage.write(key: 'isUserLoggedIn', value: 'true');
      await storage.write(key: 'accessToken', value: googleAuth.accessToken);

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      // Handle specific errors
      if (e.toString().contains('network_error')) {
        throw Exception(
            'Network error. Please check your internet connection.');
      } else if (e.toString().contains('DeadObjectException')) {
        throw Exception('Google Play Services error. Please try again.');
      }
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'accessToken');
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  bool get isSignedIn => _auth.currentUser != null;

  User? get currentUser => _auth.currentUser;
}
