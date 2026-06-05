import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAX2x_2Hi9tcdi454jii2TcA8Tq_bTcZbQ',
    appId: '1:432616962114:web:8a0ac26fead6ecc84695db',
    messagingSenderId: '432616962114',
    projectId: 'aerial-temporal',
    authDomain: 'aerial-temporal.firebaseapp.com',
    storageBucket: 'aerial-temporal.firebasestorage.app',
    measurementId: 'G-81E22332QN',
  );

}