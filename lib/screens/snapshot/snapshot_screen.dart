import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/snapshot.dart';
import '../../models/action_item.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../actions/actions_screen.dart';
import '../ai/ai_assistant_sheet.dart';
import '../settings/settings_sheet.dart';

class SnapshotScreen extends StatefulWidget {
  const SnapshotScreen({super.key});

  @override
  State<SnapshotScreen> createState() => _SnapshotScreenState();
}

class _SnapshotScreenState extends State<SnapshotScreen> {
  bool _isLoading = true;
  String? _error;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final snapshotData = await ApiService.getSnapshot();
      final actionsData = await ApiService.getActions();
      debugPrint('SNAPSHOT RESPONSE: $snapshotData');
      debugPrint('ACTIONS RESPONSE: $actionsData');
      if (!mounted) return;
      final appState = context.read<AppState>();
      appState.setSnapshot(Snapshot.fromJson(snapshotData));
      appState.setActions(
        actionsData.map((a) => ActionItem.fromJson(a)).toList(),
      );
    } catch (e, stack) {
      debugPrint('SNAPSHOT ERROR: $e');
      debugPrint('STACK: $stack');
      if (mounted) {
        setState(
          () => _error = 'Could not load your data. Is the server running?',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _isSpanish => context.read<AppState>().language == 'es';
  String _t(String en, String es) => _isSpanish ? es : en;

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ActionsScreen()),
      );
      return;
    }
    if (index == 2) {
      _showAIAssistant(context);
      return;
    }
    if (index == 3) {
      SettingsSheet.show(context);
      return;
    }
    setState(() => _navIndex = index);
  }

  void _showAIAssistant(BuildContext context) {
    AIAssistantSheet.open(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F0),
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.menu, color: Color(0xFF1A1A1A), size: 26),
        //   onPressed: () {},
        // ),
        title: const Text(
          'FinPath',
          style: TextStyle(
            color: Color(0xFF1A7A6E),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 16),
          //   child: GestureDetector(
          //     onTap: () {},
          //     child: Container(
          //       width: 40,
          //       height: 40,
          //       decoration: BoxDecoration(
          //         color: Colors.grey[300],
          //         shape: BoxShape.circle,
          //       ),
          //       child: const Icon(
          //         Icons.person_rounded,
          //         color: Colors.white,
          //         size: 24,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A7A6E)))
          : _error != null
              ? _buildError()
              : _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        selectedItemColor: const Color(0xFF1A7A6E),
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: _t('Home', 'Inicio'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.format_list_bulleted_rounded),
            label: _t('Actions', 'Acciones'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: _t('Chat', 'Chat'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            label: _t('Settings', 'Ajustes'),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7A6E),
                foregroundColor: Colors.white,
              ),
              child: Text(_t('Try again', 'Intentar de nuevo')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final appState = context.watch<AppState>();
    final snapshot = appState.snapshot;
    if (snapshot == null) return const SizedBox.shrink();

    final actions = appState.actions;
    final urgentAction = actions.firstWhere(
      (a) => !a.isCompleted,
      orElse: () => ActionItem(
        id: '',
        key: '',
        title: 'Gig Liability',
        description: '',
        educationCard: '',
        priority: 1,
        resourceId: ''
      ),
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF1A7A6E),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // Welcome header
          Text(
            _t('Welcome back', 'Bienvenido de nuevo'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _t(
              'Your financial sanctuary is looking stable today.',
              'Tu santuario financiero se ve estable hoy.',
            ),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Wellness score card
          _buildWellnessCard(snapshot),
          const SizedBox(height: 28),

          // Financial Health Breakdown
          Text(
            _t('Financial Health Breakdown', 'Resumen de Salud Financiera'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          _buildCoverageList(snapshot),
          const SizedBox(height: 20),

          // Community Goal card
          // _buildCommunityGoalCard(urgentAction),
        ],
      ),
    );
  }

  // ─── Wellness Score Card ────────────────────────────────────────────────────

  Widget _buildWellnessCard(Snapshot snapshot) {
    final score = snapshot.riskScore.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _WellnessGaugePainter(score: score.toDouble()),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t('WELLNESS SCORE', 'PUNTAJE DE BIENESTAR'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A7A6E),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _t(
                'Overall Wellness Score: $score/100',
                'Puntaje de Bienestar General: $score/100',
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Coverage List ──────────────────────────────────────────────────────────

  Widget _buildCoverageList(Snapshot snapshot) {
    final items = snapshot.coverageStatus.entries.toList();
    return Column(
      children: items.map((entry) {
        return _buildCoverageItem(
          label: entry.key,
          covered: entry.value,
        );
      }).toList(),
    );
  }

  Widget _buildCoverageItem({required String label, required bool covered}) {
    final key = label.toLowerCase();
    final isBuilding = !covered &&
        (key.contains('emergency') || key.contains('fund') || key.contains('saving'));

    final Color iconBg;
    final Color iconColor;
    final IconData icon;
    final String statusLabel;
    final Color statusBg;
    final Color statusText;
    final String sublabel;

    if (covered) {
      iconBg = const Color(0xFF1A7A6E);
      iconColor = Colors.white;
      icon = Icons.check_rounded;
      statusLabel = _t('COVERED', 'CUBIERTO');
      statusBg = const Color(0xFFE8F5F2);
      statusText = const Color(0xFF1A7A6E);
      sublabel = _t('Policy Active', 'Póliza Activa');
    } else if (isBuilding) {
      iconBg = const Color(0xFFF5A623);
      iconColor = Colors.white;
      icon = Icons.error_rounded;
      statusLabel = _t('BUILDING', 'EN PROGRESO');
      statusBg = const Color(0xFFFFF4E0);
      statusText = const Color(0xFFA06000);
      sublabel = _t('3 months target', 'Meta de 3 meses');
    } else {
      iconBg = const Color(0xFFE85C4A);
      iconColor = Colors.white;
      icon = Icons.cancel_rounded;
      statusLabel = _t('ACTION REQUIRED', 'ACCIÓN REQUERIDA');
      statusBg = const Color(0xFFE85C4A);
      statusText = Colors.white;
      sublabel = _t('Missing - Action Required', 'Faltante - Acción Requerida');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: covered ? Colors.grey[600] : (isBuilding ? Colors.grey[600] : const Color(0xFFE85C4A)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Community Goal Card ────────────────────────────────────────────────────

  Widget _buildCommunityGoalCard(ActionItem urgentAction) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('Community Goal', 'Meta Comunitaria'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _t(
                    'Join 42 others in your area securing their ${urgentAction.title} this month.',
                    'Únete a 42 personas en tu área que aseguran su ${urgentAction.title} este mes.',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ActionsScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C52),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _t('Explore Options', 'Explorar Opciones'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // People illustration
          SizedBox(
            width: 90,
            height: 90,
            child: CustomPaint(painter: _PeopleIllustrationPainter()),
          ),
        ],
      ),
    );
  }
}

// ─── Wellness Gauge Painter ────────────────────────────────────────────────────

class _WellnessGaugePainter extends CustomPainter {
  final double score;
  const _WellnessGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const startAngle = 3 * pi / 4;   // ~7 o'clock
    const totalSweep = 3 * pi / 2;   // 270°

    // Background track
    final trackPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      trackPaint,
    );

    // Filled arc
    final fillPaint = Paint()
      ..color = const Color(0xFF1A7A6E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep * (score / 100),
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_WellnessGaugePainter old) => old.score != score;
}

// ─── People Illustration Painter ──────────────────────────────────────────────

class _PeopleIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal = Paint()..color = const Color(0xFF1A7A6E);
    final amber = Paint()..color = const Color(0xFFF5A623);
    final skin = Paint()..color = const Color(0xFFE8B89A);
    final green = Paint()..color = const Color(0xFF4CAF50);

    // Ground
    final ground = Paint()..color = const Color(0xFFB8D4CC);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2),
      ground,
    );

    // Plant left
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.5, 4, size.height * 0.3),
      green,
    );
    canvas.drawOval(
      Rect.fromLTWH(0, size.height * 0.3, size.width * 0.18, size.height * 0.25),
      green,
    );

    // Person 1 (left, teal shirt)
    canvas.drawCircle(
      Offset(size.width * 0.28, size.height * 0.28),
      size.width * 0.1,
      skin,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.42, size.width * 0.2, size.height * 0.32),
      teal,
    );

    // Person 2 (middle, amber shirt)
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.22),
      size.width * 0.1,
      skin,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.36, size.width * 0.2, size.height * 0.36),
      amber,
    );

    // Person 3 (right, teal shirt)
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.28),
      size.width * 0.1,
      skin,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.65, size.height * 0.42, size.width * 0.2, size.height * 0.32),
      teal,
    );

    // Plant right
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.88, size.height * 0.5, 4, size.height * 0.3),
      green,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.78, size.height * 0.3, size.width * 0.18, size.height * 0.25),
      green,
    );
  }

  @override
  bool shouldRepaint(_PeopleIllustrationPainter old) => false;
}
