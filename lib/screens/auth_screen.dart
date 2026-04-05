import 'package:finpath/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/app_state.dart';
import 'onboarding/onboarding_screen.dart';
import 'snapshot/snapshot_screen.dart';

class AuthScreen extends StatefulWidget {
  final String language;
  const AuthScreen({super.key, required this.language});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _teal = Color(0xFF1A7A6E);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get _isEs => widget.language == 'es';
  String _t(String en, String es) => _isEs ? es : en;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> res;

      if (_isSignUp) {
        res = await ApiService.register(
          _nameController.text.trim(),
          widget.language,
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        res = await ApiService.login(
          _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      debugPrint('API response: $res');

      if (!mounted) return;

      final token = res['token'] ?? res['access_token'];
      if (token == null) {
        _showError(
          _t(
            'Error creating account, kindly try again.',
            'Error al crear la cuenta, por favor intenta de nuevo.',
          ),
        );
        return;
      }

      await AuthService.saveToken(token.toString());

      final rawUserId = res['user_id'] ?? res['id'] ?? 0;
      await AuthService.saveUserId(rawUserId.toString());

      if (!mounted) return;
      context.read<AppState>().setLanguage(widget.language);

      final hasProfile = res['has_profile'] == true;
      await AuthService.saveUserProfileStatus(hasProfile);

      if (_isSignUp || !hasProfile) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingScreen(language: widget.language),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SnapshotScreen()),
        );
      }
    } catch (e, st) {
      debugPrint('Submit error: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;
      _showError(
        _t(
          'Error creating account, kindly try again.',
          'Error al crear la cuenta, por favor intenta de nuevo.',
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4F3),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco_rounded, color: _teal, size: 18),
            const SizedBox(width: 8),
            Text(
              _t('FinPath', 'FinPath'),
              style: const TextStyle(
                color: _teal,
                fontStyle: FontStyle.italic,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Shield icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB2DFDB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: _teal,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    _t('Secure your path', 'Asegura tu camino'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _t(
                      'Join the community of 50k+ users securing\ntheir financial future.',
                      'Únete a más de 50k usuarios asegurando\nsu futuro financiero.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Google button
                  _GoogleButton(
                    label: _t('Continue with Google', 'Continuar con Google'),
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          _t('Or sign up with', 'O regístrate con'),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Full Name (sign up only)
                  if (_isSignUp) ...[
                    _FieldLabel(label: _t('Full Name', 'Nombre completo')),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'e.g. John Doe',
                      keyboardType: TextInputType.name,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? _t('Enter your name', 'Ingresa tu nombre')
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  _FieldLabel(label: _t('Email address', 'Correo electrónico')),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return _t('Enter your email', 'Ingresa tu correo');
                      }
                      if (!v.contains('@')) {
                        return _t(
                          'Enter a valid email',
                          'Ingresa un correo válido',
                        );
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password
                  _FieldLabel(label: _t('Password', 'Contraseña')),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: _t('Min. 8 characters', 'Mín. 8 caracteres'),
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFE8E8E8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return _t(
                          'Enter your password',
                          'Ingresa tu contraseña',
                        );
                      }
                      if (_isSignUp && v.length < 8) {
                        return _t(
                          'Password must be at least 8 characters',
                          'La contraseña debe tener al menos 8 caracteres',
                        );
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _teal.withValues(alpha: 0.6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isSignUp
                                  ? _t('Create Account', 'Crear Cuenta')
                                  : _t('Sign In', 'Iniciar Sesión'),
                              style: const TextStyle(
                                height: 2,

                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Toggle sign up / sign in
                  GestureDetector(
                    onTap: () => setState(() => _isSignUp = !_isSignUp),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: _isSignUp
                                ? _t(
                                    'Already have an account?  ',
                                    '¿Ya tienes cuenta?  ',
                                  )
                                : _t(
                                    'Don\'t have an account?  ',
                                    '¿No tienes cuenta?  ',
                                  ),
                          ),
                          TextSpan(
                            text: _isSignUp
                                ? _t('Sign In', 'Iniciar Sesión')
                                : _t('Sign Up', 'Registrarse'),
                            style: const TextStyle(
                              color: _teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _t('BANK-GRADE SECURITY', 'SEGURIDAD BANCARIA'),
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        Icons.shield_outlined,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'GDPR COMPLIANT',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFE8E8E8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final String label;
  const _GoogleButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Google Sign-In coming soon'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G icon (colored)
            SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(painter: _GoogleGPainter()),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue arc (top-right)
    canvas.drawArc(
      rect,
      -1.57,
      3.14,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt,
    );

    // Red arc (top-left)
    canvas.drawArc(
      rect,
      -1.57,
      -1.05,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..strokeWidth = size.width * 0.18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt,
    );

    // Yellow arc (bottom-left)
    canvas.drawArc(
      rect,
      2.09,
      1.05,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..strokeWidth = size.width * 0.18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt,
    );

    // Green arc (bottom-right)
    canvas.drawArc(
      rect,
      3.14,
      1.57,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..strokeWidth = size.width * 0.18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt,
    );

    // White horizontal bar for G shape
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - size.height * 0.09,
        radius * 0.9,
        size.height * 0.18,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
