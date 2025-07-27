import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/language_cubit.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/permission.dart';
import 'presentation/error_handle_page.dart';
import 'presentation/auth/presentation/splash_page.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log the error but don't show it to the user
    FlutterError.dumpErrorToConsole(details);
  };

  try {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory:
          kIsWeb
              ? HydratedStorageDirectory.web
              : HydratedStorageDirectory((await getTemporaryDirectory()).path),
    );
    await Quran.initialize();
    await Alarm.init();
    await AlarmPermissions.checkNotificationPermission();
    if (Alarm.android) {
      AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
    }
  } catch (e) {
    // Log initialization errors but continue with the app
    debugPrint('Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider<LanguageCubit>(create: (context) => LanguageCubit()),
      ],
      child: ErrorHandler(
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp(
                  title: 'MasjidKu',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('id'), Locale('en')],
                  locale: locale,
                  home: const SplashPage(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ErrorHandler extends StatefulWidget {
  final Widget child;

  const ErrorHandler({super.key, required this.child});

  @override
  State<ErrorHandler> createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends State<ErrorHandler> {
  FlutterErrorDetails? _errorDetails;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Override the error handler to capture errors in the widget tree
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      setState(() {
        _errorDetails = details;
        _hasError = true;
      });
    };
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return ErrorHandlerPage(errorDetails: _errorDetails, onRetry: _retry);
    }

    return widget.child;
  }
}
