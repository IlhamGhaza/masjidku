import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';

class IconHomeWidget extends StatefulWidget {
  final IconData iconName;
  final String iconDescription;
  final VoidCallback onTap;
  const IconHomeWidget({
    super.key,
    required this.iconName,
    required this.iconDescription,
    required this.onTap,
  });

  @override
  State<IconHomeWidget> createState() => _IconHomeWidgetState();
}

class _IconHomeWidgetState extends State<IconHomeWidget> {
  final List<Color> _iconColors = [
    AppTheme.lightTheme.colorScheme.primary,
    AppTheme.lightTheme.colorScheme.error,
    AppTheme.successColor,
    AppTheme.warningColor,
    AppTheme.lightTheme.colorScheme.secondary,
    AppTheme.infoColor,
    AppTheme.lightTheme.colorScheme.primaryContainer,
    AppTheme.lightTheme.colorScheme.onPrimaryContainer,
  ];

  late final Color _selectedColor;

  @override
  void initState() {
    super.initState();
    // Pilih warna secara acak saat widget diinisialisasi
    final random = Random();
    _selectedColor = _iconColors[random.nextInt(_iconColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        // final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        // final colorScheme = theme.colorScheme;
        // final screenSize = MediaQuery.of(context).size;
        return Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(10),
                // border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: IconButton(
                onPressed: widget.onTap,
                icon: Icon(widget.iconName, color: Colors.white),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.iconDescription,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
}
