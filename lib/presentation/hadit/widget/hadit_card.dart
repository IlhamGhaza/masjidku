import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

class HadithCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final String narrator;
  final String source;
  final String translation;
  final bool isBookmarked;

  const HadithCard({
    Key? key,
    required this.colorScheme,
    required this.narrator,
    required this.source,
    required this.translation,
    required this.isBookmarked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(narrator, style: TextStyle(color: colorScheme.onSurface)),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    // Implement bookmark toggle
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              source,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(translation, style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
