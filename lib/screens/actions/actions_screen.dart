import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/action_item.dart';
import '../../services/app_state.dart';
import 'action_detail_screen.dart';

// Per-step visual config derived from priority index
class _StepStyle {
  final String categoryLabel;
  final IconData categoryIcon;
  final Color categoryColor;
  final Color categoryBg;
  final Color numberBg;
  final Color buttonColor;
  final Color buttonTextColor;

  const _StepStyle({
    required this.categoryLabel,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryBg,
    required this.numberBg,
    required this.buttonColor,
    required this.buttonTextColor,
  });
}

const List<_StepStyle> _stepStyles = [
  _StepStyle(
    categoryLabel: 'Urgent',
    categoryIcon: Icons.priority_high_rounded,
    categoryColor: Color(0xFFD94F3D),
    categoryBg: Color(0xFFFDE8E6),
    numberBg: Color(0xFF1B5E3B),
    buttonColor: Color(0xFF1B5E3B),
    buttonTextColor: Colors.white,
  ),
  _StepStyle(
    categoryLabel: 'Stability Goal',
    categoryIcon: Icons.savings_rounded,
    categoryColor: Color(0xFF7B5B2C),
    categoryBg: Color(0xFFF5EDD8),
    numberBg: Color(0xFFB0BEC5),
    buttonColor: Color(0xFFCFE8F5),
    buttonTextColor: Color(0xFF1A3A4A),
  ),
  _StepStyle(
    categoryLabel: 'Protection',
    categoryIcon: Icons.home_work_rounded,
    categoryColor: Color(0xFF1B5E3B),
    categoryBg: Color(0xFFE0F0EA),
    numberBg: Color(0xFFB0BEC5),
    buttonColor: Color(0xFFE8E8E8),
    buttonTextColor: Color(0xFF333333),
  ),
];

_StepStyle _styleFor(int index) =>
    _stepStyles[index.clamp(0, _stepStyles.length - 1)];

class ActionsScreen extends StatelessWidget {
  const ActionsScreen({super.key});

  String _t(BuildContext context, String en, String es) {
    final lang = context.read<AppState>().language;
    return lang == 'es' ? es : en;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final actions = appState.actions;
    final t = (String en, String es) => _t(context, en, es);

    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2EDE4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FinPath',
          style: TextStyle(
            color: Color(0xFF1A7A6E),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: actions.isEmpty
            ? Center(
                child: Text(
                  t(
                    'No actions yet. Complete onboarding first.',
                    'Sin acciones aún. Completa el cuestionario primero.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            : CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('ACTION PLAN', 'PLAN DE ACCIÓN'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E3B),
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t(
                              'Your Next ${actions.length} Steps',
                              'Tus Próximos ${actions.length} Pasos',
                            ),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t(
                              'Tailored guidance to strengthen your financial sanctuary.',
                              'Orientación personalizada para fortalecer tu bienestar financiero.',
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Action cards
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _ActionCard(
                          action: actions[i],
                          index: i,
                        ),
                        childCount: actions.length,
                      ),
                    ),
                  ),
                  // Need Help card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      child: _NeedHelpCard(t: t),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final ActionItem action;
  final int index;

  const _ActionCard({required this.action, required this.index});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  String _t(String en, String es) {
    final lang = context.read<AppState>().language;
    return lang == 'es' ? es : en;
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final style = _styleFor(widget.index);
    final stepNumber = widget.index + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: action.isCompleted
                  ? const Color(0xFF1B5E3B)
                  : style.numberBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: action.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '$stepNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActionDetailScreen(action: action),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: style.categoryBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              style.categoryIcon,
                              size: 13,
                              color: style.categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _t(style.categoryLabel, style.categoryLabel),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: style.categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        action.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: action.isCompleted
                              ? Colors.grey
                              : const Color(0xFF1A1A1A),
                          decoration: action.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        action.description,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tell Me More button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActionDetailScreen(action: action),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: style.buttonColor,
                            foregroundColor: style.buttonTextColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _t('Tell Me More', 'Saber Más'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: style.buttonTextColor,
                                ),
                              ),
                              if (widget.index == 0) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: style.buttonTextColor,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeedHelpCard extends StatelessWidget {
  final String Function(String en, String es) t;

  const _NeedHelpCard({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E3B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Decorative background icon
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.headset_mic_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('Need Help?', '¿Necesitas Ayuda?'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t(
                  'Connect with a wellness coach to discuss these steps.',
                  'Conéctate con un asesor para hablar sobre estos pasos.',
                ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF5DBEA3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  t('Chat with an Expert', 'Habla con un Experto'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
