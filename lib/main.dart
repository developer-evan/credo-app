import 'package:credo_faster/screens/auth/login/login.dart';
import 'package:credo_faster/screens/home.dart';
import 'package:credo_faster/screens/onboarding.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Satoshi'),
      home: const Onboarding(),
      routes: {
        '/home': (context) => const Home(),
        '/login': (context) => const Login()
      },
    );
  }
}

