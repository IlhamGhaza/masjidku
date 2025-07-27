import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class SeeAllWidget extends StatelessWidget {
  final ColorScheme colorScheme;
  final BuildContext context;
  final String text;
  final VoidCallback onTap;

  const SeeAllWidget({
    super.key,
    required this.colorScheme,
    required this.context,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: onTap,
            child: Text(
              AppLocalizations.of(context)!.see_all,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
