import 'package:flutter/material.dart';
import '../../core/sound_manager.dart';

class TutorialOverlay extends StatefulWidget {
  final String title;
  final String description;
  final List<String> steps;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const TutorialOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.steps,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF121212).withValues(alpha: 0.95),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  HapticManager.selectionClick();
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: widget.steps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          widget.steps[index].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w200,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onSkip,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        color: Colors.white24,
                        letterSpacing: 2,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  _buildNextButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return OutlinedButton(
      onPressed: () {
        HapticManager.mediumImpact();
        if (_currentPage < widget.steps.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          widget.onComplete();
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white38, width: 0.5),
        shape: const RoundedRectangleBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        _currentPage < widget.steps.length - 1 ? 'NEXT' : 'START',
        style: const TextStyle(
          color: Colors.white,
          letterSpacing: 2,
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

class PuzzleTimer extends StatelessWidget {
  final int remainingSeconds;
  final bool isWarning;

  const PuzzleTimer({
    super.key,
    required this.remainingSeconds,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isWarning
              ? Colors.redAccent.withValues(alpha: 0.5)
              : Colors.white10,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: Colors.white38),
          const SizedBox(width: 8),
          Text(
            timeString,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w200,
              color: isWarning ? Colors.redAccent : Colors.white70,
              letterSpacing: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class HintButton extends StatelessWidget {
  final int hintsRemaining;
  final VoidCallback onTap;

  const HintButton({
    super.key,
    required this.hintsRemaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: hintsRemaining > 0
          ? () {
              HapticManager.lightImpact();
              onTap();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: hintsRemaining > 0 ? Colors.white24 : Colors.white10,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 14,
              color: hintsRemaining > 0 ? Colors.white70 : Colors.white10,
            ),
            const SizedBox(width: 8),
            Text(
              'HINT ($hintsRemaining)',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w300,
                color: hintsRemaining > 0 ? Colors.white70 : Colors.white10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
