import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured for SafeWear.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-nBps86qwmM42nEucBy6rNdkBeTSviAU',
    appId: '1:1060743667195:android:d654b7982b3ccd46627f5e',
    messagingSenderId: '1060743667195',
    projectId: 'safewear-124e6',
    storageBucket: 'safewear-124e6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBltRXrQIdBqwPW6ZMoScktN_rWd82d-EM',
    appId: '1:1060743667195:ios:a64611a7231d5d43627f5e',
    messagingSenderId: '1060743667195',
    projectId: 'safewear-124e6',
    storageBucket: 'safewear-124e6.firebasestorage.app',
    iosBundleId: 'com.safewear',
  );
}
