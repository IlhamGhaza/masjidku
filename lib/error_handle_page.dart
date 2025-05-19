import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_cubit.dart';

class ErrorHandlerPage extends StatefulWidget {
  final FlutterErrorDetails? errorDetails;
  final VoidCallback onRetry;

  const ErrorHandlerPage({Key? key, this.errorDetails, required this.onRetry})
    : super(key: key);

  @override
  State<ErrorHandlerPage> createState() => _ErrorHandlerPageState();
}

class _ErrorHandlerPageState extends State<ErrorHandlerPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        final colorScheme = theme.colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Header with mosque icon
                    Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mosque_rounded,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                        ),
                    const SizedBox(height: 32),

                    // Error title
                    Text(
                          context.tr('oops_something_went_wrong'),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          delay: 200.ms,
                        ),
                    const SizedBox(height: 16),

                    // Error message
                    Text(
                          context.tr('app_encountered_error'),
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onBackground.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          delay: 400.ms,
                        ),
                    const SizedBox(height: 48),

                    // Illustration
                    Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 60,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.tr('please_restart_app'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.tr('we_apologize_for_inconvenience'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 600.ms)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                          duration: 800.ms,
                          delay: 600.ms,
                        ),
                    const SizedBox(height: 48),

                    // Retry button
                    ElevatedButton(
                          onPressed: widget.onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            context.tr('retry'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 800.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 800.ms,
                          delay: 800.ms,
                        ),
                    const SizedBox(height: 16),

                    // Go home button
                    OutlinedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            minimumSize: const Size(double.infinity, 56),
                            side: BorderSide(color: colorScheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            context.tr('go_to_home'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 1000.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 800.ms,
                          delay: 1000.ms,
                        ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension ColorExtension on Color {
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromRGBO(
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
      alpha ?? this.opacity,
    );
  }
}
