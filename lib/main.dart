import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import 'core/providers.dart';
import 'core/notification_service.dart';
import 'core/sound_manager.dart';
import 'core/utils/game_flow_optimizer.dart';
import 'core/utils/responsive_utils.dart';
import 'data/repositories/database_service.dart';
import 'features/onboarding/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GameFlowOptimizer.optimizeMemoryUsage();

  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF030712),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  runApp(const ProviderScope(child: GAASApp()));
}

class GAASApp extends ConsumerWidget {
  const GAASApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);

    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFF030712),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'SYSTEM_INIT_FAILURE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => main(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('RETRY_INITIALIZATION'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF030712),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                      strokeWidth: 2,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'STABILIZING_CORE_SYSTEMS...',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        letterSpacing: 4,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          key: ValueKey(currentLocale.code),
          title: 'GAAS',
          debugShowCheckedModeBanner: false,
          theme: AdaptiveTheme.getAdaptiveTheme(context, currentTheme),
          locale: Locale(currentLocale.code),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SplashScreen(),
          builder: (context, child) {
            if (ResponsiveUtils.isWindows()) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: child!,
              );
            }
            return child!;
          },
        );
      },
    );
  }
}

Future<void> _initializeApp() async {
  try {
    // Database is critical for almost all features
    await DatabaseService.instance.timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('Database initialization timed out'),
    );

    // Initialize non-critical services with individual error handling
    // This ensures that if one service (like Sound) fails, the app can still start
    await Future.wait([
      HapticManager.instance.initialize().catchError((e) {
        debugPrint('Haptics initialization failed: $e');
      }),
      SoundManager.instance.initialize().catchError((e) {
        debugPrint('SoundManager initialization failed: $e');
      }),
      NotificationService().initialize().catchError((e) {
        debugPrint('NotificationService initialization failed: $e');
      }),
    ]);

    // Attempt to play startup sound, but don't let it crash the app
    try {
      await SoundManager.instance.playStartupSound();
    } catch (e) {
      debugPrint('Failed to play startup sound: $e');
    }
  } catch (e) {
    debugPrint('CRITICAL_INITIALIZATION_ERROR: $e');
    rethrow;
  }
}
