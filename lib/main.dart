import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'auth/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform.copyWith(
        authDomain: kIsWeb ? 'buddi-94585.firebaseapp.com' : null,
      ),
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification service init error: $e');
  }

  runApp(const BuddiApp());
}

class BuddiApp extends StatelessWidget {
  const BuddiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buddi App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'GoogleSansFlex',
      ),
      home: const SignInPage(), 
    );
  }
}
