import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for the app.
///
/// To configure this with your own Firebase project:
/// 1. Go to Firebase Console (https://console.firebase.google.com)
/// 2. Create a new project or use an existing one
/// 3. Add an iOS app (for iOS) and/or Android app (for Android)
/// 4. Download the google-services.json (Android) or GoogleService-Info.plist (iOS)
/// 5. Replace the values below with your Firebase project credentials
///
/// For web, you'll need to create a web app in Firebase Console and use the
/// provided configuration.
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

  // Replace with your Firebase Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC2t7IPXV2zf0nYzg7LKZOPmFvK_uSeU0I',
    appId: '1:941655992458:android:ccb187f91720c77c97a573',
    messagingSenderId: '941655992458',
    projectId: 'employee-attendance-app-57baa',
    authDomain: 'employee-attendance-app-57baa.firebaseapp.com',
    storageBucket: 'employee-attendance-app-57baa.appspot.com',
  );

  // Replace with your Firebase Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2t7IPXV2zf0nYzg7LKZOPmFvK_uSeU0I',
    appId: '1:941655992458:android:ccb187f91720c77c97a573',
    messagingSenderId: '941655992458',
    projectId: 'employee-attendance-app-57baa',
    storageBucket: 'employee-attendance-app-57baa.appspot.com',
  );

  // Replace with your Firebase iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC2t7IPXV2zf0nYzg7LKZOPmFvK_uSeU0I',
    appId: '1:941655992458:android:ccb187f91720c77c97a573',
    messagingSenderId: '941655992458',
    projectId: 'employee-attendance-app-57baa',
    storageBucket: 'employee-attendance-app-57baa.appspot.com',
    iosBundleId: 'com.example.employeeAttendanceApp',
  );

  // Replace with your Firebase macOS configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC2t7IPXV2zf0nYzg7LKZOPmFvK_uSeU0I',
    appId: '1:941655992458:android:ccb187f91720c77c97a573',
    messagingSenderId: '941655992458',
    projectId: 'employee-attendance-app-57baa',
    storageBucket: 'employee-attendance-app-57baa.appspot.com',
    iosBundleId: 'com.example.employeeAttendanceApp',
  );

  // Replace with your Firebase Windows configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC2t7IPXV2zf0nYzg7LKZOPmFvK_uSeU0I',
    appId: '1:941655992458:android:ccb187f91720c77c97a573',
    messagingSenderId: '941655992458',
    projectId: 'employee-attendance-app-57baa',
    storageBucket: 'employee-attendance-app-57baa.appspot.com',
  );
}
