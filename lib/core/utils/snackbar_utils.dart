import 'package:flutter/material.dart';

class SnackbarUtils {
  final String text;
  final Color backgroundColor;
  //icon
  IconData? icon;

  SnackbarUtils({required this.text, required this.backgroundColor, this.icon});
  void showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon?? Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  void showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

}
