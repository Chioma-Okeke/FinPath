import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/action_item.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import 'action_detail_screen.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        title: Text(_t(context, 'Your Action Plan', 'Tu Plan de Acción')),
      ),
      body: actions.isEmpty
          ? Center(
              child: Text(
                _t(context, 'No actions yet. Complete onboarding first.',
                    'Sin acciones aún. Completa el cuestionario primero.'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: actions.length,
              itemBuilder: (context, i) =>
                  _ActionCard(action: actions[i], index: i),
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
  bool _isLoading = false;

  String _t(String en, String es) {
    final lang = context.read<AppState>().language;
    return lang == 'es' ? es : en;
  }

  Future<void> _markComplete() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.completeAction(widget.action.id);
      if (!mounted) return;
      context.read<AppState>().markActionComplete(widget.action.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('Error updating action', 'Error al actualizar'))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActionDetailScreen(action: action),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: action.isCompleted
                    ? Colors.green[700]
                    : const Color(0xFF0D3B66),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _t('Step ${action.priority}', 'Paso ${action.priority}'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (action.isCompleted)
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ActionDetailScreen(action: action),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0D3B66),
                            side: const BorderSide(
                                color: Color(0xFF0D3B66)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(_t('Learn more', 'Saber más')),
                        ),
                      ),
                      if (!action.isCompleted) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _markComplete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : Text(_t('Done', 'Listo')),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
