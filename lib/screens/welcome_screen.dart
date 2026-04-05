import 'package:finpath/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/app_state.dart';
import 'auth_screen.dart';
import 'snapshot/snapshot_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedLang = 'en';

  static const _teal = Color(0xFF1A7A6E);

  Future<void> _proceed() async {
    final appState = context.read<AppState>();
    appState.setLanguage(_selectedLang);
    await AuthService.saveLanguage(_selectedLang);

    if (!mounted) return;

    final language = await AuthService.getLanguage();
    final isLoggedIn = await AuthService.isLoggedIn();
    final hasProfileKey = await AuthService.getUserProfileStatus();
    if (!mounted) return;

    if (isLoggedIn) {
      if (hasProfileKey) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SnapshotScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OnboardingScreen(language: language)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen(language: _selectedLang)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD6EDE9), Color(0xFFF2F4F3)],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // Logo icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: _teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 16),

                // App name
                const Text(
                  'FinPath',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _teal,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 4),

                // Tagline
                Text(
                  'Your Financial Sanctuary',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 36),

                // Hero headline
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(text: "Let's begin your\njourney to "),
                      TextSpan(
                        text: 'stability',
                        style: TextStyle(
                          color: _teal,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Body copy
                Text(
                  "Wellness starts with a single step. We're here to guide you through your finances with kindness, not judgment.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 28),

                // Privacy badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded, color: _teal, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Private, secure, and built for you.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Language label
                Text(
                  'SELECT YOUR LANGUAGE',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),

                const SizedBox(height: 14),

                // English option
                _LanguageTile(
                  title: 'English',
                  subtitle: 'Default Language',
                  selected: _selectedLang == 'en',
                  trailing: _selectedLang == 'en'
                      ? const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        )
                      : const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF999999),
                          size: 20,
                        ),
                  onTap: () => setState(() => _selectedLang = 'en'),
                ),

                const SizedBox(height: 10),

                // Español option
                _LanguageTile(
                  title: 'Español',
                  subtitle: 'Seleccionar idioma',
                  selected: _selectedLang == 'es',
                  trailing: Icon(
                    Icons.language_rounded,
                    color: _selectedLang == 'es' ? Colors.white : _teal,
                    size: 22,
                  ),
                  onTap: () => setState(() => _selectedLang = 'es'),
                ),

                const SizedBox(height: 32),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _proceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _selectedLang == 'es' ? 'Continuar' : 'Get Started',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'INCLUSIVE FINANCIAL GUIDANCE',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final Widget trailing;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A7A6E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.75)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
