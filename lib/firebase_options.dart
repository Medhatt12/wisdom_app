import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDdAXblVu0F0TOMkVkCIGP4-KwloNqkVhI',
    appId: '1:672555705798:web:6346c22c1fe142b4ebfec7',
    messagingSenderId: '672555705798',
    projectId: 'wisdom-app-62f23',
    authDomain: 'wisdom-app-62f23.firebaseapp.com',
    storageBucket: 'wisdom-app-62f23.appspot.com',
    measurementId: 'G-JVF0PZQ18P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9F1UQ1mTJ0KK9FhZUJEWNmiM2tflGh64',
    appId: '1:672555705798:android:a91ee9e8ad52dc87ebfec7',
    messagingSenderId: '672555705798',
    projectId: 'wisdom-app-62f23',
    storageBucket: 'wisdom-app-62f23.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-xgIjQ9ukWWTdCJ1t8I0poqtj3_4cDws',
    appId: '1:672555705798:ios:d522cda29d887080ebfec7',
    messagingSenderId: '672555705798',
    projectId: 'wisdom-app-62f23',
    storageBucket: 'wisdom-app-62f23.appspot.com',
    iosBundleId: 'tech.medhat.wisdomApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD-xgIjQ9ukWWTdCJ1t8I0poqtj3_4cDws',
    appId: '1:672555705798:ios:52cd7ec1f124e79febfec7',
    messagingSenderId: '672555705798',
    projectId: 'wisdom-app-62f23',
    storageBucket: 'wisdom-app-62f23.appspot.com',
    iosBundleId: 'com.example.wisdomApp.RunnerTests',
  );
}
