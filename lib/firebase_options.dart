// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDvYG_Zm9nvYXRX1_EwP0F6TdO8tLPxYPg',
    appId: '1:850850719464:web:6c5db28aba43be4d134b5d',
    messagingSenderId: '850850719464',
    projectId: 'paytrack-349b9',
    authDomain: 'paytrack-349b9.firebaseapp.com',
    storageBucket: 'paytrack-349b9.appspot.com',
    measurementId: 'G-ER2L2JL6VL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQ_daJCkA5maAgx-xZR594USRU5SM1jM0',
    appId: '1:850850719464:android:34f74365abeee41a134b5d',
    messagingSenderId: '850850719464',
    projectId: 'paytrack-349b9',
    storageBucket: 'paytrack-349b9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAFxX6fltlQxu2q7H68Ppl2aDn6ItkLn-A',
    appId: '1:850850719464:ios:e6220d3fa00ad376134b5d',
    messagingSenderId: '850850719464',
    projectId: 'paytrack-349b9',
    storageBucket: 'paytrack-349b9.appspot.com',
    iosBundleId: 'com.example.paytrack',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAFxX6fltlQxu2q7H68Ppl2aDn6ItkLn-A',
    appId: '1:850850719464:ios:618179b7704bec59134b5d',
    messagingSenderId: '850850719464',
    projectId: 'paytrack-349b9',
    storageBucket: 'paytrack-349b9.appspot.com',
    iosBundleId: 'com.example.paytrack.RunnerTests',
  );
}
