import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
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
    apiKey: 'AIzaSyBmEhDAZQ2e8cddbB1m5Y9fhK2kmm-D05o',
    appId: '1:838140609303:android:14c6a955d392aa1725ed52',
    messagingSenderId: '838140609303',
    projectId: 'expense-tracker-app-34570',
    storageBucket: 'expense-tracker-app-34570.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmEhDAZQ2e8cddbB1m5Y9fhK2kmm-D05o',
    appId: '1:838140609303:ios:6f7a6c9d2e1b4a3c2e1f2a', // Typical iOS ID format
    messagingSenderId: '838140609303',
    projectId: 'expense-tracker-app-34570',
    storageBucket: 'expense-tracker-app-34570.firebasestorage.app',
    iosBundleId: 'com.example.expense_tracker_app',
  );
}
