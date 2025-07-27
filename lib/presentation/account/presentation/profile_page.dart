import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjidku/core/theme/theme_cubit.dart';
import 'package:masjidku/core/theme/theme.dart';
import 'package:masjidku/presentation/auth/presentation/login_page.dart';
import 'package:masjidku/presentation/account/widget/language_selector_widget.dart';
import 'package:masjidku/l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.profile),
            backgroundColor: colorScheme.primary,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Username',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'Email',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              AppLocalizations.of(context)!.edit_profile,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _textSettings(
                          isDarkMode,
                          AppLocalizations.of(context)!.appearance,
                        ),
                        const SizedBox(height: 10),
                        _switchTheme(isDarkMode, context),
                        const SizedBox(height: 15),
                        _textSettings(
                          isDarkMode,
                          AppLocalizations.of(context)!.language,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: LanguageSelectorWidget(
                            isDarkMode: isDarkMode,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _textSettings(
                          isDarkMode,
                          AppLocalizations.of(context)!.latest_activity,
                        ),
                        const SizedBox(height: 10),
                        _buildLatestActivity(isDarkMode),
                        const SizedBox(height: 20),
                        _buildLogoutButton(context, colorScheme),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Text _textSettings(bool isDarkMode, final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        color: isDarkMode ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _switchTheme(bool isDarkMode, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDarkMode
                      ? AppLocalizations.of(context)!.light_mode
                      : AppLocalizations.of(context)!.dark_mode,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  isDarkMode
                      ? AppLocalizations.of(context)!.light_mode_description
                      : AppLocalizations.of(context)!.dark_mode_description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              context.read<ThemeCubit>().updateTheme(
                value ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),

          // SizedBox(
          //   width: 80,
          //   height: 40,
          //   child: Stack(
          //     alignment: Alignment.center,
          //     children: [
          //       Switch(
          //         value: isDarkMode,
          //         onChanged: (value) {
          //           context.read<ThemeCubit>().updateTheme(
          //             value ? ThemeMode.dark : ThemeMode.light,
          //           );
          //         },
          //       ),
          //       Positioned(
          //         left: 15,
          //         child: Icon(Icons.light_mode, color: Colors.amber, size: 10),
          //       ),
          //       Positioned(
          //         right: 15,
          //         child: Icon(Icons.dark_mode, color: Colors.indigo, size: 10),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLatestActivity(bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xff2E8B57),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(Icons.settings, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Donasi untuk Pembangunan',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 10,
                children: [
                  Text(
                    '5 April 2025',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff2E8B57),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Berhasil',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text('Apakah Anda yakin ingin keluar?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Tidak'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Anda berhasil logout'),
                      ),
                    );
                  },
                  child: const Text('Ya'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.logout,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
