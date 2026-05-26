import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/themes/app_themes.dart';
import '../../core/sound_manager.dart';
import '../profile_setup/profile_setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _backgroundController;
  late Animation<Alignment> _gradientAnimation;
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'GAAS',
      subtitle: 'Core Concept',
      description:
          'A gamified adaptive arithmetic system that personalizes math practice with instant feedback and rewarding progression.',
      icon: Icons.qr_code_scanner_rounded,
      accentColor: AppDesignTokens.neonCyan,
    ),
    OnboardingPageData(
      title: 'ADVENTURE',
      subtitle: 'Campaign Progression',
      description:
          'Progress through chapter-based missions, unlock new stages, and build streaks as your skills evolve.',
      icon: Icons.track_changes_rounded,
      accentColor: AppDesignTokens.neonPink,
    ),
    OnboardingPageData(
      title: 'CHALLENGE',
      subtitle: 'Arcade + Daily Missions',
      description:
          'Jump into fast arcade modes, complete daily goals, and compete for top scores under pressure.',
      icon: Icons.bolt_rounded,
      accentColor: AppDesignTokens.neonYellow,
    ),
    OnboardingPageData(
      title: 'PUZZLES',
      subtitle: 'Crosswords + Math Riddles',
      description:
          'Solve crossword clues, arithmetic riddles, number sequences, and logic challenges in a single puzzle hub.',
      icon: Icons.psychology_rounded,
      accentColor: AppDesignTokens.neonCyan,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _gradientAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticManager.selectionClick();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    HapticManager.lightImpact();
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_intro', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ProfileSetupScreen(isInitialSetup: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _pages[_currentPage].accentColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient Animation
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: _gradientAnimation.value,
                  end: _gradientAnimation.value == Alignment.topLeft
                      ? Alignment.bottomRight
                      : Alignment.topLeft,
                  colors: [
                    const Color(0xFF0A0A0A),
                    accent.withValues(alpha: 0.05),
                    const Color(0xFF0A0A0A),
                  ],
                ),
              ),
            ),
          ),

          // HUD Scanlines effect (simple overlay)
          Opacity(
            opacity: 0.03,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/scanline.png',
                  ), // Fallback if missing
                  repeat: ImageRepeat.repeat,
                  onError: (e, s) {},
                ),
              ),
            ),
          ),

          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              HapticManager.lightImpact();
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Top Bar - Progress and Skip
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minimalist Progress
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.only(right: 8),
                      width: _currentPage == index ? 32 : 8,
                      height: 4, // Increased height for visibility
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? accent
                            : accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          if (_currentPage == index)
                            BoxShadow(
                              color: accent.withValues(alpha: 0.5),
                              blurRadius: 12,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'SKIP >>',
                 style: theme.textTheme.labelSmall?.copyWith(
                   color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                   letterSpacing: 2,
                   fontWeight: FontWeight.bold,
                 ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 60,
            left: 32,
            right: 32,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      color: accent, // Solid color for better visibility
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'GET STARTED'
                                : 'NEXT',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.black, // High contrast
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with Glow
          Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: page.accentColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: page.accentColor.withValues(alpha: 0.05),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(page.icon, size: 80, color: page.accentColor),
              )
              .animate(key: ValueKey('icon_${page.title}'))
              .fadeIn(duration: 800.ms)
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),

          const SizedBox(height: 64),

           // Title
           Text(
                 page.title,
                 style: theme.textTheme.headlineMedium?.copyWith(
                   color: theme.colorScheme.onSurface,
                   fontWeight: FontWeight.w900,
                   letterSpacing: 8,
                   shadows: [
                     Shadow(
                       color: page.accentColor.withValues(alpha: 0.5),
                       blurRadius: 15,
                     ),
                   ],
                 ),
                 textAlign: TextAlign.center,
               )
              .animate(key: ValueKey('title_${page.title}'))
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 12),

          // Subtitle
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: page.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  page.subtitle.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: page.accentColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              )
              .animate(key: ValueKey('subtitle_${page.title}'))
              .fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 32),

          // Description
          Text(
                page.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                  height: 1.8,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              )
              .animate(key: ValueKey('desc_${page.title}'))
              .fadeIn(delay: 600.ms, duration: 600.ms),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
