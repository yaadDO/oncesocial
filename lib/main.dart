import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oncesocial/config/firebase_options.dart';
import 'app.dart';
import 'features/notifications/notifs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
     FirebaseApi.initNotifications();
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  runApp(MyApp());
}

