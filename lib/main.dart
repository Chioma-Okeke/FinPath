import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/snapshot/snapshot_screen.dart';

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
      home: const _AuthGate(),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.ltr, child: child!),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    final hasProfile = isLoggedIn && await AuthService.getUserProfileStatus();
    final lang = await AuthService.getLanguage();

    if (!mounted) return;

    context.read<AppState>().setLanguage(lang);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            (isLoggedIn && hasProfile) ? const SnapshotScreen() : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F5F0),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF1A7A6E)),
      ),
    );
  }
}
