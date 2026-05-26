import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import 'core/providers.dart';
import 'core/notification_service.dart';
import 'core/utils/game_flow_optimizer.dart';
import 'core/utils/responsive_utils.dart';
import 'data/repositories/database_service.dart';
import 'features/onboarding/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-specific setup
  if (Platform.isAndroid || Platform.isIOS) {
    // Mobile-specific settings
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop-specific settings - allow multiple orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // Initialize performance optimizations
  GameFlowOptimizer.optimizeMemoryUsage();

  try {
    // Initialize database first (fastest)
    final dbInit = DatabaseService.instance;

    final container = ProviderContainer();

    // Parallel initialization for better performance
    final futures = [
      dbInit,
      container.read(userSessionProvider.notifier).initializeUser(),
      container.read(themeProvider.notifier).loadTheme(),
      container.read(localeProvider.notifier).loadLocale(),
      container.read(settingsProvider.notifier).loadSettings(),
      container.read(levelProgressProvider.notifier).loadProgress(),
    ];

    await Future.wait(futures);

    // Sync SoundManager with loaded Settings
    final settings = container.read(settingsProvider);
    container.read(soundManagerProvider).setMuted(!settings.soundEnabled);

    // Initialize Notification Service (non-blocking)
    NotificationService().initialize();

    runApp(
      UncontrolledProviderScope(container: container, child: const GAASApp()),
    );
  } catch (e) {
    debugPrint('Initialization error: $e');
    runApp(const ProviderScope(child: GAASApp()));
  }
}

class GAASApp extends ConsumerWidget {
  const GAASApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'GAAS',
      debugShowCheckedModeBanner: false,
      theme: AdaptiveTheme.getAdaptiveTheme(context, currentTheme),
      locale: Locale(currentLocale.code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
      builder: (context, child) {
        // Ensure proper scaling on desktop
        if (ResponsiveUtils.isWindows()) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling, // Prevent system text scaling on desktop
            ),
            child: child!,
          );
        }
        return child!;
      },
      // Enable performance overlay in debug mode for monitoring
      showPerformanceOverlay: false, // Set to true to enable performance monitoring
    );
  }
}
