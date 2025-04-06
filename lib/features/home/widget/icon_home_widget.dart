import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';

class _UsedIndices {
  static final _UsedIndices instance = _UsedIndices._();
  final Set<int> _indices = {};

  _UsedIndices._();

  bool contains(int index) => _indices.contains(index);
  void add(int index) => _indices.add(index);
  void clear() => _indices.clear();
  int get length => _indices.length;
}

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
   int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    final usedIndices = _UsedIndices.instance;

    do {
      _selectedIndex = Random().nextInt(_iconColors.length);
    } while (usedIndices.contains(_selectedIndex));

    usedIndices.add(_selectedIndex);

    if (usedIndices.length == _iconColors.length) {
      usedIndices.clear();
    }

    _selectedColor = _iconColors[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;

        return Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(10),
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
