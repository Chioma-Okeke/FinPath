import 'package:flutter/material.dart';

class EducationCard extends StatefulWidget {
  final String content;
  const EducationCard({super.key, required this.content});

  @override
  State<EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<EducationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0D3B66).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined,
                      color: Color(0xFF0D3B66), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Learn about this',
                      style: TextStyle(
                        color: Color(0xFF0D3B66),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF0D3B66),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                widget.content,
                style: const TextStyle(
                  color: Color(0xFF333333),
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
