import 'package:flutter/material.dart';
import 'dart:ui';

class GlassmorphicIconWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const GlassmorphicIconWidget({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
