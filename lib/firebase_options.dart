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
    apiKey: 'AIzaSyBAY6OxR8S2k2igbDmmrr7O34XLFwIaVAs',
    appId: '1:379877617885:web:9dab462ac48f0263636b34',
    messagingSenderId: '379877617885',
    projectId: 'familymedicine-ef41c',
    authDomain: 'familymedicine-ef41c.firebaseapp.com',
    storageBucket: 'familymedicine-ef41c.appspot.com',
    measurementId: 'G-XVS6JCGYBQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3wu3F8kD4d4IOqhwVr7FAypiKjPxprvg',
    appId: '1:379877617885:android:9438b7edf0d026c1636b34',
    messagingSenderId: '379877617885',
    projectId: 'familymedicine-ef41c',
    storageBucket: 'familymedicine-ef41c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALDe_GnfTIOkoROyAiJf5TfBKqLyn9tWI',
    appId: '1:379877617885:ios:b8e1f954afc636b2636b34',
    messagingSenderId: '379877617885',
    projectId: 'familymedicine-ef41c',
    storageBucket: 'familymedicine-ef41c.appspot.com',
    iosBundleId: 'com.example.familyMedicine',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyALDe_GnfTIOkoROyAiJf5TfBKqLyn9tWI',
    appId: '1:379877617885:ios:b8e1f954afc636b2636b34',
    messagingSenderId: '379877617885',
    projectId: 'familymedicine-ef41c',
    storageBucket: 'familymedicine-ef41c.appspot.com',
    iosBundleId: 'com.example.familyMedicine',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBAY6OxR8S2k2igbDmmrr7O34XLFwIaVAs',
    appId: '1:379877617885:web:a67a657552131641636b34',
    messagingSenderId: '379877617885',
    projectId: 'familymedicine-ef41c',
    authDomain: 'familymedicine-ef41c.firebaseapp.com',
    storageBucket: 'familymedicine-ef41c.appspot.com',
    measurementId: 'G-0SVXR6YEQ3',
  );
}
