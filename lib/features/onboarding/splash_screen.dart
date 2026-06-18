import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers.dart';
import '../../core/themes/app_themes.dart';
import '../../core/sound_manager.dart';

import '../../shared/widgets/main_navigation_scaffold.dart';
import '../profile_setup/profile_setup_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _bgController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
    ]).animate(_mainController);
    _logoOpacity = CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn));

    _mainController.forward();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)),
        ref.read(appStartupProvider.future),
      ]);

      if (!mounted) return;

      await HapticManager.instance.initialize();
      await SoundManager.instance.initialize();
      SoundManager.instance.playStartupSound();

      await _navigateToNext();
    } catch (e) {
      // Error is handled in the build method via ref.watch(appStartupProvider)
    }
  }

  Future<void> _navigateToNext() async {
    final prefs = await SharedPreferences.getInstance();
    final seenIntro = prefs.getBool('seen_intro') ?? false;
    final hasCustomization = prefs.getBool('has_customization') ?? false;
    final user = ref.read(userSessionProvider);
    final hasCompleteProfile =
        user != null && user.name.trim().isNotEmpty && user.avatarShape.trim().isNotEmpty;

    // New flow: Splash → Intro → User Customization → Home
    final Widget next = !seenIntro
        ? const OnboardingScreen()
        : (!hasCustomization || !hasCompleteProfile
              ? const ProfileSetupScreen(isInitialSetup: true)
              : const MainNavigationScaffold());

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => next,
        transitionDuration: const Duration(milliseconds: 700),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startupState = ref.watch(appStartupProvider);

    // Modern Deep Dark Palette
    final bg = AppDesignTokens.background;
    final primary = AppDesignTokens.primary;
    final secondary = AppDesignTokens.secondary;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Dynamic mesh-style background
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, child) {
              final a = _bgController.value * math.pi * 2;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(math.cos(a) * 0.5, math.sin(a) * 0.5),
                    radius: 1.5,
                    colors: [
                      primary.withValues(alpha: 0.12),
                      secondary.withValues(alpha: 0.08),
                      bg,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              );
            },
          ),
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (_, child) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modern Glassmorphic Logo Container
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.2),
                              blurRadius: 40,
                              spreadRadius: -10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.calculate_rounded,
                            size: 72,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'GAAS',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: AppDesignTokens.textPrimary,
                          letterSpacing: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'LOGIC • ARITHMETIC • PUZZLES',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: secondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      if (startupState.hasError)
                         Column(
                           children: [
                             Text(
                               'Initialization Error',
                               style: theme.textTheme.bodyMedium?.copyWith(color: AppDesignTokens.error),
                             ),
                             const SizedBox(height: 16),
                             OutlinedButton(
                               onPressed: () {
                                 ref.invalidate(appStartupProvider);
                                 _boot();
                               },
                               child: const Text('RETRY'),
                             )
                           ],
                         )
                      else
                        SizedBox(
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              backgroundColor: Colors.white.withValues(alpha: 0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(primary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
