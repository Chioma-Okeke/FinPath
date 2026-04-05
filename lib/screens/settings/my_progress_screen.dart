import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/action_item.dart';
import '../../services/api_service.dart';

class MyProgressScreen extends StatefulWidget {
  const MyProgressScreen({super.key});

  @override
  State<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends State<MyProgressScreen> {
  List<ActionItem> _completed = [];
  int _pendingCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await ApiService.getActions();
      final all = raw
          .map((a) => ActionItem.fromJson(a as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _completed = all.where((a) => a.isCompleted).toList();
          _pendingCount = all.where((a) => !a.isCompleted).length;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load progress.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Financial Sanctuary',
          style: TextStyle(
            color: Color(0xFF1A7A6E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A7A6E)),
            )
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                // HISTORY label
                const Text(
                  'HISTORY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 6),

                // Title
                const Text(
                  'Your Achievements',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  "You're making great progress! Every step forward is a milestone toward your financial sanctuary.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Total completed card
                _TotalCard(count: _completed.length),
                const SizedBox(height: 28),

                // Completed items
                if (_completed.isNotEmpty) ...[
                  const Text(
                    'COMPLETED ITEMS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._completed.map((action) => _CompletedItem(action: action)),
                  const SizedBox(height: 24),
                ] else ...[
                  const _EmptyState(),
                  const SizedBox(height: 24),
                ],

                // Keep the Momentum card
                _MomentumCard(pendingCount: _pendingCount),
              ],
            ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final int count;
  const _TotalCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A7A6E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Actions Completed',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xCCFFFFFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedItem extends StatelessWidget {
  final ActionItem action;
  const _CompletedItem({required this.action});

  @override
  Widget build(BuildContext context) {
    final dateLabel = action.completedAt != null
        ? 'Completed on ${DateFormat('MMM dd, yyyy').format(action.completedAt!)}'
        : 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F5F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF1A7A6E),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCCCCCC),
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F5F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFF1A7A6E),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No completed actions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start completing your action plan to see your achievements here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentumCard extends StatelessWidget {
  final int pendingCount;
  const _MomentumCard({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFECECE8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keep the\nMomentum!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A7A6E),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pendingCount > 0
                      ? 'You have $pendingCount pending action${pendingCount == 1 ? '' : 's'} to reach your next milestone.'
                      : "You've completed all your actions. Amazing work!",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A7A6E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Next Steps',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF1A7A6E),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
