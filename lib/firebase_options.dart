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
    apiKey: 'AIzaSyBt_E-OVSmu7dlxkN4KcGU4FhbRN6JjaA0',
    appId: '1:959258951524:web:7e3fdc90a4b0fe0bfb8471',
    messagingSenderId: '959258951524',
    projectId: 'universe-264dd',
    authDomain: 'universe-264dd.firebaseapp.com',
    databaseURL: 'https://universe-264dd-default-rtdb.firebaseio.com',
    storageBucket: 'universe-264dd.appspot.com',
    measurementId: 'G-534PV32QXC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqV0rVM2sHkf0o7CaB6eWiUH14bofdzvs',
    appId: '1:959258951524:android:70d9b1c0c32ec392fb8471',
    messagingSenderId: '959258951524',
    projectId: 'universe-264dd',
    databaseURL: 'https://universe-264dd-default-rtdb.firebaseio.com',
    storageBucket: 'universe-264dd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA7jHvX7NmFdxPEtQILtJU2I0zLVcC9b-Y',
    appId: '1:959258951524:ios:ee058b6901f47579fb8471',
    messagingSenderId: '959258951524',
    projectId: 'universe-264dd',
    databaseURL: 'https://universe-264dd-default-rtdb.firebaseio.com',
    storageBucket: 'universe-264dd.appspot.com',
    iosBundleId: 'com.example.universe',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA7jHvX7NmFdxPEtQILtJU2I0zLVcC9b-Y',
    appId: '1:959258951524:ios:ee058b6901f47579fb8471',
    messagingSenderId: '959258951524',
    projectId: 'universe-264dd',
    databaseURL: 'https://universe-264dd-default-rtdb.firebaseio.com',
    storageBucket: 'universe-264dd.appspot.com',
    iosBundleId: 'com.example.universe',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBt_E-OVSmu7dlxkN4KcGU4FhbRN6JjaA0',
    appId: '1:959258951524:web:bcfd6d74d12d58cbfb8471',
    messagingSenderId: '959258951524',
    projectId: 'universe-264dd',
    authDomain: 'universe-264dd.firebaseapp.com',
    databaseURL: 'https://universe-264dd-default-rtdb.firebaseio.com',
    storageBucket: 'universe-264dd.appspot.com',
    measurementId: 'G-NZM05B1557',
  );
}
