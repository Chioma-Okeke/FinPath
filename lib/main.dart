import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const FinPathApp(),
    ),
  );
}

class FinPathApp extends StatelessWidget {
  const FinPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinPath',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3B66),
          primary: const Color(0xFF0D3B66),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.ltr, child: child!),
    );
  }
}
