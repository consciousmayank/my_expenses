// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDsH2sBXxGP1sEPh1SNjwCARCX6wxlPkiw',
    appId: '1:257610787314:web:38e02d1b908225538e236b',
    messagingSenderId: '257610787314',
    projectId: 'my-expenses-tracker',
    authDomain: 'my-expenses-tracker-4f6dc.firebaseapp.com',
    storageBucket: 'my-expenses-tracker.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBc_Wcb_z2igLwQkUrL8Nj5OQVYnBTHwyk',
    appId: '1:257610787314:android:38ddce9dcb19916a8e236b',
    messagingSenderId: '257610787314',
    projectId: 'my-expenses-tracker',
    storageBucket: 'my-expenses-tracker.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBckSuaMr0fw3xVHgcJzRVDDJ4ffIH9xn8',
    appId: '1:257610787314:ios:2a9d1a67ac358ba08e236b',
    messagingSenderId: '257610787314',
    projectId: 'my-expenses-tracker',
    storageBucket: 'my-expenses-tracker.firebasestorage.app',
    iosBundleId: 'com.mayank.joshi.expensemanager.expenseManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBckSuaMr0fw3xVHgcJzRVDDJ4ffIH9xn8',
    appId: '1:257610787314:ios:2a9d1a67ac358ba08e236b',
    messagingSenderId: '257610787314',
    projectId: 'my-expenses-tracker',
    storageBucket: 'my-expenses-tracker.firebasestorage.app',
    iosBundleId: 'com.mayank.joshi.expensemanager.expenseManager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDsH2sBXxGP1sEPh1SNjwCARCX6wxlPkiw',
    appId: '1:257610787314:web:618783fe8960a86c8e236b',
    messagingSenderId: '257610787314',
    projectId: 'my-expenses-tracker',
    authDomain: 'my-expenses-tracker-4f6dc.firebaseapp.com',
    storageBucket: 'my-expenses-tracker.firebasestorage.app',
  );
}
