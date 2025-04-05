import 'package:flutter/material.dart';

// import '../theme/theme.dart';

enum ButtonStyle { filled, outlined }

class Button extends StatelessWidget {
  const Button.filled({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyle.filled,
    this.color,
    this.textColor,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 16.0,
    this.icon,
    this.disabled = false,
    this.fontSize = 16.0,
  });

  const Button.outlined({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyle.outlined,
    this.color,
    this.textColor,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 16.0,
    this.icon,
    this.disabled = false,
    this.fontSize = 16.0,
  });

  final Function() onPressed;
  final String label;
  final ButtonStyle style;
  final Color? color;
  final Color? textColor;
  final double width;
  final double height;
  final double borderRadius;
  final Widget? icon;
  final bool disabled;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use theme colors if not provided
    final buttonColor =
        color ??
        (style == ButtonStyle.filled
            ? theme.colorScheme.primary
            : Colors.transparent);

    final buttonTextColor =
        textColor ??
        (style == ButtonStyle.filled
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary);

    final borderColor =
        style == ButtonStyle.outlined
            ? theme.colorScheme.primary
            : Colors.transparent;

    return SizedBox(
      height: height,
      width: width,
      child:
          style == ButtonStyle.filled
              ? ElevatedButton(
                onPressed: disabled ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: buttonTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 10.0)],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
              : OutlinedButton(
                onPressed: disabled ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: buttonTextColor,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 10.0)],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
