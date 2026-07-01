// File generated manually from google-services.json.
// Re-generate with: flutterfire configure --project=card-connect-1
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        // TODO: Register iOS app in Firebase Console and add iOS options here.
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS yet.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgCJF7Op3Vm3_uUulY5QfV_GIRNjlTt5o',
    appId: '1:170780952647:android:b8bb42e3475b59732e0962',
    messagingSenderId: '170780952647',
    projectId: 'card-connect-1',
    storageBucket: 'card-connect-1.firebasestorage.app',
  );
}
