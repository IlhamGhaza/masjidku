import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/language_cubit.dart';
import '../../../l10n/app_localizations.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final bool isDarkMode;
  final ColorScheme colorScheme;

  const LanguageSelectorWidget({
    super.key,
    required this.isDarkMode,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, currentLocale) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0, // Mengurangi padding horizontal
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Menggunakan mainAxisSize.min
              children: [
                _buildLanguageOption(
                  context,
                  AppLocalizations.of(context)!.indonesian,
                  'id',
                  currentLocale.languageCode,
                ),
                _buildLanguageOption(
                  context,
                  AppLocalizations.of(context)!.english,
                  'en',
                  currentLocale.languageCode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String displayName,
    String languageCode,
    String selectedLanguageCode,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            displayName,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            overflow:
                TextOverflow
                    .ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
          ),
        ),
        Radio(
          value: languageCode,
          groupValue: selectedLanguageCode,
          onChanged: (value) {
            if (value != null) {
              context.read<LanguageCubit>().changeLanguage(value.toString());
            }
          },
          activeColor: colorScheme.primary,
        ),
      ],
    );
  }
}
