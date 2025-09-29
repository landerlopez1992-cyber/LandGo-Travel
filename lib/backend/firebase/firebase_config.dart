import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDyBBPSXrrRnO3DXUdxTjft5JSUU_0lTrg",
            authDomain: "land-go-travel-khmzio.firebaseapp.com",
            projectId: "land-go-travel-khmzio",
            storageBucket: "land-go-travel-khmzio.firebasestorage.app",
            messagingSenderId: "585042333882",
            appId: "1:585042333882:web:d0cd9b6e0586977662f283"));
  } else {
    await Firebase.initializeApp();
  }
}
