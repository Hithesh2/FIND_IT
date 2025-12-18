import 'package:find_it_app/core/screens/main_screen.dart';
import 'package:find_it_app/features/auth/presentation/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- import Riverpod

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      home: const SignUpPage(), // <-- now can safely use Riverpod providers
    );
  }
}
