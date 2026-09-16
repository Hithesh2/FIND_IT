import 'package:find_it_app/features/auth/presentation/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- import Riverpod

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyASNQPhB7pA8fYvuGgtQRBQwvg7i_DQ6C8',
        appId: '1:247268508070:android:e75857ac91dd2bd3dccf67',
        messagingSenderId: '247268508070',
        projectId: 'findit-app-c01e2',
        storageBucket: 'findit-app-c01e2.firebasestorage.app',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Find It App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}
