import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers.dart';
import '../../core/sound_manager.dart';
import '../../core/themes/app_themes.dart';
import '../home/presentation/home_screen.dart';
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
    unawaited(_boot());
    SoundManager().playStartupSound();
  }

  Future<void> _boot() async {
    try {
      await ref.read(userSessionProvider.notifier).initializeUser();
      await ref.read(levelProgressRepositoryProvider).initializeLevels();
      await ref.read(levelProgressProvider.notifier).loadProgress();
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _navigateToNext();
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
              : const HomeScreen());

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

    // Use dark theme colors
    final bg = const Color(0xFF0A0A0A);
    final cyan = AppDesignTokens.neonCyan;
    final pink = AppDesignTokens.neonPink;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, child) {
              final a = _bgController.value * math.pi * 2;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(math.cos(a), math.sin(a)),
                    end: Alignment(-math.cos(a), -math.sin(a)),
                    colors: [
                      bg,
                      cyan.withValues(alpha: 0.08),
                      pink.withValues(alpha: 0.06),
                      bg,
                    ],
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
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: bg.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cyan.withValues(alpha: 0.7),
                            width: 2
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cyan.withValues(alpha: 0.4),
                              blurRadius: 32
                            ),
                            BoxShadow(
                              color: pink.withValues(alpha: 0.25),
                              blurRadius: 36
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.calculate_rounded,
                          size: 64,
                          color: cyan
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'GAAS',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          letterSpacing: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'LOGIC - ARITHMETIC - PUZZLES',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cyan.withValues(alpha: 0.75),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 150,
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          color: cyan
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
