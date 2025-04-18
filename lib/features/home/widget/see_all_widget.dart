import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SeeAllWidget extends StatelessWidget {
  final ColorScheme colorScheme;
  final BuildContext context;
  final String text;
  final VoidCallback onTap;

  const SeeAllWidget({
    Key? key,
    required this.colorScheme,
    required this.context,
    required this.text,
    required this.onTap,
  }) : super(key: key);

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
              color: colorScheme.onBackground,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: onTap,
            child: Text(
              context.tr("see_all"),
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
