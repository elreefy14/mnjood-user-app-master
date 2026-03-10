import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration options for web platform.
/// Android and iOS use google-services.json / GoogleService-Info.plist respectively.
///
/// To regenerate, run: flutterfire configure
class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD0Z911mOoWCVkeGdjhIKwWFPRgvd6ZyAw',
    authDomain: 'stackmart-500c7.firebaseapp.com',
    projectId: 'stackmart-500c7',
    storageBucket: 'stackmart-500c7.firebasestorage.app',
    messagingSenderId: '491987943015',
    appId: '1:491987943015:web:d8bc7ab8dbc9991c8f1ec2',
  );
}
