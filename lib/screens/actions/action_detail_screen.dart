import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/action_item.dart';
import '../../services/app_state.dart';
import '../../widgets/education_card.dart';
import '../ai/ai_assistant_sheet.dart';

class ActionDetailScreen extends StatelessWidget {
  final ActionItem action;

  const ActionDetailScreen({super.key, required this.action});

  String _t(BuildContext context, String en, String es) {
    final lang = context.read<AppState>().language;
    return lang == 'es' ? es : en;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        title: Text(_t(context, 'Action Detail', 'Detalle de Acción')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Priority badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B66),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _t(context, 'Priority ${action.priority}',
                      'Prioridad ${action.priority}'),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              if (action.isCompleted) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _t(context, 'Completed', 'Completado'),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            action.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B66),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            action.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF444444),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // Education card
          if (action.educationCard.isNotEmpty)
            EducationCard(content: action.educationCard),

          const SizedBox(height: 24),

          // State Farm product link
          if (action.productLink != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8B84B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: Color(0xFFE8B84B)),
                      const SizedBox(width: 8),
                      Text(
                        _t(context, 'State Farm Can Help',
                            'State Farm puede ayudarte'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D3B66),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.productLink!,
                    style: const TextStyle(color: Color(0xFF444444)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Ask AI button
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AIAssistantSheet(),
            ),
            icon: const Icon(Icons.smart_toy_outlined),
            label: Text(_t(context, 'Ask FinPath AI about this',
                'Pregunta a FinPath AI sobre esto')),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D3B66),
              side: const BorderSide(color: Color(0xFF0D3B66)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
