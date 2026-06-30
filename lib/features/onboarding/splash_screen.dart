import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sound_manager.dart';

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
    final bootStart = DateTime.now();

    // The startupProvider now handles initialization.
    // We wait for it to be ready.
    // However, since SplashScreen is shown when isReady is false,
    // and startupProvider starts _init in constructor,
    // we just need to make sure the splash shows for a minimum duration.

    SoundManager.instance.playStartupSound();

    final elapsed = DateTime.now().difference(bootStart);
    if (elapsed < const Duration(seconds: 3)) {
      await Future.delayed(const Duration(seconds: 3) - elapsed);
    }

    // In a state-driven app, Main.dart switches the screen based on startupState.
    // If SplashScreen is used as a standalone screen that navigates,
    // it should be consistent with the logic in Main.dart.
    // But Main.dart currently returns SplashScreen() if !isReady.
    // So if _init finishes, Main.dart will automatically swap SplashScreen for something else.
    // This _boot is only for visual timing if Main.dart is the driver.
  }

  // Removed navigation logic as Main.dart handles it via startupState


  @override
  void dispose() {
    _mainController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = theme.scaffoldBackgroundColor;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

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
                          color: theme.colorScheme.onSurface,
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