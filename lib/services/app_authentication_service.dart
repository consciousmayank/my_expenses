import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class AppAuthenticationService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file', // For specific files created by the app
      // Or use 'https://www.googleapis.com/auth/drive.appdata' // For application-specific folder
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to check token validity
  Future<bool> _isTokenValid(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=$token'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Token validation request error: $e');
      return false;
    }
  }

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

  Future<void> expireToken() async {
    try {
      // Get current access token
      final currentToken = await getAccessToken();
      if (currentToken != null) {
        // Revoke the access token
        final response = await http.get(
          Uri.parse(
              'https://accounts.google.com/o/oauth2/revoke?token=$currentToken'),
        );

        if (response.statusCode != 200) {
          print('Error revoking token: ${response.statusCode}');
        }
      }

      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _auth.signOut();

      // Clear stored tokens
      // const storage = FlutterSecureStorage();
      // await storage.delete(key: 'isUserLoggedIn');
      // await storage.delete(key: 'accessToken');
    } catch (e) {
      print('Error expiring token: $e');
    }
  }

  // Future<String?> getAccessToken() async {
  //   const storage = FlutterSecureStorage();
  //   return await storage.read(key: 'accessToken');
  // }

  Future<({String? token, String? error})> checkAndRefreshToken() async {
    try {
      // Get current access token
      final currentToken = await getAccessToken();
      if (currentToken == null) {
        return (token: null, error: 'No access token found');
      }

      // Check if current token is valid
      final isValid = await _isTokenValid(currentToken);
      if (isValid) {
        return (token: currentToken, error: null);
      }

      // Token is invalid, try to refresh
      final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      if (currentUser == null) {
        return (token: null, error: 'Please login again');
      }

      try {
        // Try to refresh token
        final GoogleSignInAuthentication googleAuth =
            await currentUser.authentication;

        // Save new token
        const storage = FlutterSecureStorage();
        await storage.write(key: 'accessToken', value: googleAuth.accessToken);

        return (token: googleAuth.accessToken, error: null);
      } catch (e) {
        // Refresh token is expired, need to login again
        await _googleSignIn.signOut();
        await _auth.signOut();
        const storage = FlutterSecureStorage();
        await storage.delete(key: 'isUserLoggedIn');
        await storage.delete(key: 'accessToken');
        return (token: null, error: 'Session expired. Please login again');
      }
    } catch (e) {
      print('Error checking/refreshing token: $e');
      return (token: null, error: e.toString());
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Check Google Play Services first
      final hasGooglePlayServices = await checkGooglePlayServices();
      if (!hasGooglePlayServices && Platform.isAndroid) {
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

  logout() async {
    await signOut();
  }
}
