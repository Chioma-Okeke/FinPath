import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/snapshot.dart';
import '../../models/action_item.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../actions/actions_screen.dart';
import '../ai/ai_assistant_sheet.dart';

class SnapshotScreen extends StatefulWidget {
  const SnapshotScreen({super.key});

  @override
  State<SnapshotScreen> createState() => _SnapshotScreenState();
}

class _SnapshotScreenState extends State<SnapshotScreen> {
  bool _isLoading = true;
  String? _error;

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
      // print(" snapshot");
      // print(snapshotData);

      // print(actionsData);
      // print("actionsData");

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

  Color _riskColor(String level) {
    switch (level) {
      case 'Critical':
        return Colors.red[700]!;
      case 'High':
        return Colors.orange[700]!;
      case 'Medium':
        return Colors.amber[700]!;
      default:
        return Colors.green[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        title: Text(_t('My Financial Snapshot', 'Mi Perfil Financiero')),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAIAssistant(context),
        backgroundColor: const Color(0xFFE8B84B),
        foregroundColor: const Color(0xFF0D3B66),
        icon: const Icon(Icons.smart_toy_outlined),
        label: Text(_t('Ask FinPath AI', 'Pregunta a FinPath AI')),
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRiskCard(snapshot),
          const SizedBox(height: 16),
          _buildCoverageGrid(snapshot),
          const SizedBox(height: 16),
          _buildActionPlanPreview(appState.actions),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildRiskCard(Snapshot snapshot) {
    final color = _riskColor(snapshot.riskLevel);
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Your Risk Score', 'Tu Puntuación de Riesgo'),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${snapshot.riskScore}',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    snapshot.riskLevel,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          if (snapshot.biggestRisk.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      snapshot.biggestRisk,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoverageGrid(Snapshot snapshot) {
    final coverage = snapshot.coverageStatus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('Coverage Status', 'Estado de Cobertura'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D3B66),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: coverage.entries.map((entry) {
            final covered = entry.value;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: covered ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: covered ? Colors.green[200]! : Colors.red[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    covered ? Icons.check_circle : Icons.cancel,
                    color: covered ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: covered ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionPlanPreview(List<ActionItem> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _t('Your Next Steps', 'Tus Próximos Pasos'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3B66),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActionsScreen()),
              ),
              child: Text(_t('See all', 'Ver todo')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...actions
            .take(3)
            .map(
              (action) =>
                  _ActionPreviewTile(action: action, isSpanish: _isSpanish),
            ),
      ],
    );
  }

  void _showAIAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AIAssistantSheet(),
    );
  }
}

class _ActionPreviewTile extends StatelessWidget {
  final ActionItem action;
  final bool isSpanish;

  const _ActionPreviewTile({required this.action, required this.isSpanish});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0D3B66),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${action.priority}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: action.isCompleted
                    ? Colors.grey
                    : const Color(0xFF333333),
                decoration: action.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          if (action.isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}
