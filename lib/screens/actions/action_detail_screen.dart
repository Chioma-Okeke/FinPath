import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/action_item.dart';
import '../../models/resource.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../ai/ai_assistant_sheet.dart';

class ActionDetailScreen extends StatefulWidget {
  final ActionItem action;

  const ActionDetailScreen({super.key, required this.action});

  @override
  State<ActionDetailScreen> createState() => _ActionDetailScreenState();
}

class _ActionDetailScreenState extends State<ActionDetailScreen> {
  Resource? _resource;
  bool _loading = true;
  bool _learnExpanded = false;

  String _t(String en, String es) {
    final lang = context.read<AppState>().language;
    return lang == 'es' ? es : en;
  }

  @override
  void initState() {
    super.initState();
    _loadResource();
  }

  Future<void> _loadResource() async {
    try {
      final resource = await ApiService.getResource(widget.action.resourceId);
      if (mounted) setState(() { _resource = resource; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markComplete() async {
    await ApiService.completeAction(widget.action.key);
    if (!mounted) return;
    context.read<AppState>().markActionComplete(widget.action.key);
    Navigator.pop(context);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;

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
          'Financial Sanctuary',
          style: TextStyle(
            color: Color(0xFF1A7A6E),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1A7A6E),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: action.isCompleted ? null : _markComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E3B),
                disabledBackgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                action.isCompleted
                    ? _t('Completed', 'Completado')
                    : _t('Mark as Complete', 'Marcar como Completado'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E3B)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8573F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _t('PRIORITY ${action.priority}', 'PRIORIDAD ${action.priority}'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Action title
                Text(
                  action.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B2E1B),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Action description
                Text(
                  action.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF555555),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),

                // Learn about this (expandable)
                if (_resource != null && _resource!.whyItMatters.isNotEmpty)
                  _LearnCard(
                    content: _resource!.whyItMatters,
                    expanded: _learnExpanded,
                    onToggle: () => setState(() => _learnExpanded = !_learnExpanded),
                    label: _t('Learn about this', 'Aprende sobre esto'),
                  ),

                const SizedBox(height: 20),

                // Ask FinPath AI card
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AIAssistantSheet(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E3B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('Ask FinPath AI about this',
                                    'Pregunta a FinPath AI sobre esto'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _resource != null
                                    ? _t(
                                        'Instant answers about ${_resource!.category.toLowerCase()}',
                                        'Respuestas instantáneas sobre ${_resource!.category.toLowerCase()}',
                                      )
                                    : _t(
                                        'Get instant answers from AI',
                                        'Obtén respuestas instantáneas de IA',
                                      ),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ),

                // Resource / provider card
                if (_resource != null) ...[
                  const SizedBox(height: 20),
                  _ProviderCard(
                    resource: _resource!,
                    onExplore: _resource!.learnMoreUrl.isNotEmpty
                        ? () => _openUrl(_resource!.learnMoreUrl)
                        : null,
                    exploreLabel: _t('Explore Policies', 'Explorar Pólizas'),
                    canHelpLabel: _t(
                      '${_resource!.provider.toUpperCase()} CAN HELP',
                      '${_resource!.provider.toUpperCase()} PUEDE AYUDAR',
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _LearnCard extends StatelessWidget {
  final String content;
  final bool expanded;
  final VoidCallback onToggle;
  final String label;

  const _LearnCard({
    required this.content,
    required this.expanded,
    required this.onToggle,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF1B5E3B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF555555),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF444444),
                  height: 1.6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback? onExplore;
  final String exploreLabel;
  final String canHelpLabel;

  const _ProviderCard({
    required this.resource,
    required this.onExplore,
    required this.exploreLabel,
    required this.canHelpLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area with label overlay
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  color: const Color(0xFF1B5E3B).withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.landscape_outlined,
                    size: 64,
                    color: Color(0xFF1B5E3B),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      canHelpLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider title + icon
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${resource.provider} ${resource.category}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.directions_car_outlined,
                        size: 20,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  resource.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
                if (resource.typicalCost.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    resource.typicalCost,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1B5E3B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onExplore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCFE8F5),
                      foregroundColor: const Color(0xFF1A3A4A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      exploreLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
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
}
