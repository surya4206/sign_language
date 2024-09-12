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
    apiKey: 'AIzaSyD8plJGnFwOEboHh0_rHtUQimQjuMN8TSI',
    appId: '1:970934661305:web:9e581cbb8152c987ba2b68',
    messagingSenderId: '970934661305',
    projectId: 'signlanguage-b11de',
    authDomain: 'signlanguage-b11de.firebaseapp.com',
    storageBucket: 'signlanguage-b11de.appspot.com',
    measurementId: 'G-Y03KBZ1YBM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqylDHl1cyM7YVhPWWdrJWWnoYQeb0b1Q',
    appId: '1:970934661305:android:a5b3e35a88b6372fba2b68',
    messagingSenderId: '970934661305',
    projectId: 'signlanguage-b11de',
    storageBucket: 'signlanguage-b11de.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHnbZi4y6NzbsCekUlMsZ4C519RG2miOs',
    appId: '1:970934661305:ios:35737b37fe360188ba2b68',
    messagingSenderId: '970934661305',
    projectId: 'signlanguage-b11de',
    storageBucket: 'signlanguage-b11de.appspot.com',
    iosBundleId: 'com.example.signLanguageProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBHnbZi4y6NzbsCekUlMsZ4C519RG2miOs',
    appId: '1:970934661305:ios:35737b37fe360188ba2b68',
    messagingSenderId: '970934661305',
    projectId: 'signlanguage-b11de',
    storageBucket: 'signlanguage-b11de.appspot.com',
    iosBundleId: 'com.example.signLanguageProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD8plJGnFwOEboHh0_rHtUQimQjuMN8TSI',
    appId: '1:970934661305:web:809007010fd782d0ba2b68',
    messagingSenderId: '970934661305',
    projectId: 'signlanguage-b11de',
    authDomain: 'signlanguage-b11de.firebaseapp.com',
    storageBucket: 'signlanguage-b11de.appspot.com',
    measurementId: 'G-9BEYRX25C3',
  );
}
