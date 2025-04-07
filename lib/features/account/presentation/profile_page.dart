import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../auth/presentation/login_page.dart';
import '../widget/language_selector_widget.dart';

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
        final screenSize = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: Text(context.tr('profile')),
            backgroundColor: colorScheme.primary,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                            child: Text(context.tr('edit_profile')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 15,
                      children: [
                        _textSettings(isDarkMode, 'appearance'.tr()),
                        _switchTheme(isDarkMode, context),
                        _textSettings(isDarkMode, 'language'.tr()),
                        Container(
                          width: double.infinity,
                          height: 130,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: LanguageSelectorWidget(
                              isDarkMode: isDarkMode,
                              colorScheme: colorScheme,
                            ),
                          ),
                        ),
                        // _textSettings(isDarkMode, 'account_settings'.tr()),
                        _textSettings(isDarkMode, 'latest_activity'.tr()),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xff2E8B57),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(Icons.settings, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Donasi untuk Pembangunan',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      '5 April 2025 ',
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xff2E8B57),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Berhasil',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        //container logout
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Konfirmasi'),
                                  content: Text(
                                    'Apakah Anda yakin ingin keluar?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Tidak'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // logout
                                        // context.read<AuthBloc>().add(
                                        //   AuthLogoutRequested(),
                                        // );
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => const LoginPage(),
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                              'Anda berhasil logout',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text('Ya'),
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
                                context.tr('logout'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
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

  //
  Widget _switchTheme(bool isDarkMode, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 95,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDarkMode
                        ? context.tr('light_mode')
                        : context.tr('dark_mode'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
                  ),
                  Text(
                    isDarkMode
                        ? context.tr('light_mode_description')
                        : context.tr('dark_mode_description'),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
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
      ),
    );
  }

  //
}
