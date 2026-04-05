import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../../services/auth_service.dart';
import '../welcome_screen.dart';
import 'my_progress_screen.dart';
import 'resources_screen.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  String? _name;
  String? _lifeSituations;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiService.getMe();
      final user = data['user'] as Map<String, dynamic>?;
      final profile = data['profile'] as Map<String, dynamic>?;

      final name = user?['name'] as String?;
      final situations = (profile?['life_situations'] as List<dynamic>?)
          ?.map((e) => e.toString().split("_").join(" "))
          .toList();

      if (!mounted) return;
      setState(() {
        _name = name;
        _lifeSituations = (situations != null && situations.isNotEmpty)
            ? situations.join(', ')
            : null;
        _loading = false;
      });

      // Sync name to AppState if not already set
      if (name != null && name.isNotEmpty) {
        context.read<AppState>().setUserName(name);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isEs = appState.language == 'es';
    String t(String en, String es) => isEs ? es : en;

    final displayName = _name?.isNotEmpty == true
        ? _name!
        : (appState.userName.isNotEmpty ? appState.userName : 'User');
    final subtitle =
        _lifeSituations ?? t('FinPath Member', 'Miembro de FinPath');

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A7A6E)),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    children: [
                      // Profile header
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4DB6AC),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    displayName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFF5F5F0),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // Menu items
                      _MenuItem(
                        icon: Icons.trending_up_rounded,
                        label: t('My Progress', 'Mi Progreso'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyProgressScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.language_rounded,
                        label: t('Language', 'Idioma'),
                        onTap: () => _showLanguageModal(context, appState, t),
                      ),
                      // _MenuItem(
                      //   icon: Icons.people_rounded,
                      //   label: t('Community', 'Comunidad'),
                      //   onTap: () {},
                      // ),
                      _MenuItem(
                        icon: Icons.menu_book_rounded,
                        label: t('Resources', 'Recursos'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResourcesScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.help_rounded,
                        label: t('Support', 'Soporte'),
                        onTap: () {},
                      ),

                      const SizedBox(height: 32),

                      // Logout
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => _logout(context, t),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFFFECEA),
                            foregroundColor: const Color(0xFFD94F3D),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                t('Log Out', 'Cerrar Sesión'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showLanguageModal(
    BuildContext context,
    AppState appState,
    String Function(String, String) t,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _LanguageDialog(appState: appState),
    );
  }

  Future<void> _logout(
    BuildContext context,
    String Function(String, String) t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t('Log out?', '¿Cerrar sesión?')),
        content: Text(
          t(
            'You will need to sign in again to access your account.',
            'Necesitarás iniciar sesión de nuevo para acceder a tu cuenta.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('Cancel', 'Cancelar')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD94F3D),
            ),
            child: Text(t('Log Out', 'Cerrar Sesión')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (_) => false,
        );
      }
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF1A7A6E), size: 24),
              const SizedBox(width: 18),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageDialog extends StatefulWidget {
  final AppState appState;
  const _LanguageDialog({required this.appState});

  @override
  State<_LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<_LanguageDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.appState.language;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _selected == 'es' ? 'Idioma' : 'Language',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangOption(
            flag: '🇺🇸',
            label: 'English',
            selected: _selected == 'en',
            onTap: () => setState(() => _selected = 'en'),
          ),
          const SizedBox(height: 8),
          _LangOption(
            flag: '🇪🇸',
            label: 'Español',
            selected: _selected == 'es',
            onTap: () => setState(() => _selected = 'es'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_selected == 'es' ? 'Cancelar' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            widget.appState.setLanguage(_selected);
            AuthService.saveLanguage(_selected);
            Navigator.pop(context);
            try {
              await ApiService.updateLanguage(_selected);
            } catch (_) {}
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A7A6E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(_selected == 'es' ? 'Guardar' : 'Save'),
        ),
      ],
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0F2EF) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF1A7A6E) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? const Color(0xFF1A7A6E)
                    : const Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1A7A6E),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
