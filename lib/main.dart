import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oncesocial/config/firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}



