// Generated-like file (manually filled) for this project.
// If you want to regenerate automatically, use FlutterFire CLI: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        // You can add iOS/macOS/windows/linux later if you need them.
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // Web App (Firebase Console -> Project settings -> Your apps -> Web app -> Config)
  static const FirebaseOptions web = FirebaseOptions(
    // IMPORTANT: Must be a valid API key for your Firebase project.
    // Synced with android/app/google-services.json (current_key).
    apiKey: 'AIzaSyAuqTUvKGUUmXCOJMWpCjsYdibS6w2W2Y4',
    appId: '1:811028797099:web:11022000f600879ee109ee',
    messagingSenderId: '811028797099',
    projectId: 'harmony-project-42f2a',
    authDomain: 'harmony-project-42f2a.firebaseapp.com',
    storageBucket: 'harmony-project-42f2a.firebasestorage.app',
    measurementId: 'G-XQHL7BVQ2F',
  );

  // Android App (Firebase Console -> Project settings -> Your apps -> Android app)
  // NOTE: for Android builds you still need android/app/google-services.json.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAuqTUvKGUUmXCOJMWpCjsYdibS6w2W2Y4',
    appId: '1:811028797099:android:484d23645939d25fe109ee',
    messagingSenderId: '811028797099',
    projectId: 'harmony-project-42f2a',
    storageBucket: 'harmony-project-42f2a.firebasestorage.app',
  );
}
