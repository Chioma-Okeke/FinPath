import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  List<dynamic> _resources = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getResources();
      if (mounted) setState(() { _resources = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load resources.'; _loading = false; });
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Resources',
          style: TextStyle(color: Color(0xFF1A7A6E), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A7A6E)))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Color(0xFF1A1A1A),
                        ),
                        children: [
                          TextSpan(text: 'Your Financial\n'),
                          TextSpan(
                            text: 'Safety Net',
                            style: TextStyle(color: Color(0xFF1A7A6E)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Curated tools and protection to secure your financial future.',
                      style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ..._resources.map((r) => _ResourceCard(resource: r as Map<String, dynamic>)),
                    const SizedBox(height: 8),
                    const _ExpertCard(),
                  ],
                ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final Map<String, dynamic> resource;

  const _ResourceCard({required this.resource});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = resource['category'] as String? ?? '';
    final title = resource['title'] as String? ?? '';
    final description = resource['description'] as String? ?? '';
    final provider = resource['provider'] as String? ?? '';
    final typicalCost = resource['typical_cost'] as String? ?? '';
    final whyItMatters = resource['why_it_matters'] as String? ?? '';
    final whoNeedsIt = (resource['who_needs_it'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final learnMoreUrl = resource['learn_more_url'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category + cost row
            Row(
              children: [
                _CategoryBadge(label: category),
                const SizedBox(width: 10),
                _CostBadge(cost: typicalCost),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Provider
            if (provider.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFF1A7A6E),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PROVIDER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFF888888),
                        ),
                      ),
                      Text(
                        provider,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // Why it matters quote
            if (whyItMatters.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '"$whyItMatters"',
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Who needs it tags
            if (whoNeedsIt.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: whoNeedsIt
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0EC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF444444)),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Learn More button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: learnMoreUrl.isNotEmpty ? () => _launchUrl(learnMoreUrl) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Learn More',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EEF5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Color(0xFF2A6E7E),
        ),
      ),
    );
  }
}

class _CostBadge extends StatelessWidget {
  final String cost;
  const _CostBadge({required this.cost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_rounded, size: 13, color: Color(0xFF888888)),
          const SizedBox(width: 4),
          Text(
            cost,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF444444),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A7A6E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need expert advice?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Schedule a 15-minute sanctuary session with our wellness guides.',
            style: TextStyle(fontSize: 14, color: Color(0xCCFFFFFF), height: 1.4),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A7A6E),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text(
              'Book a Call',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
