import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../logic/custom_mix_provider.dart';
import '../../../data/models/math_riddle.dart';
import '../../../core/sound_manager.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/providers.dart';
import '../../game/ui/game_screen.dart';
import '../../../l10n/generated/app_localizations.dart';

class CustomMixScreen extends ConsumerStatefulWidget {
  const CustomMixScreen({super.key});

  @override
  ConsumerState<CustomMixScreen> createState() => _CustomMixScreenState();
}

class _CustomMixScreenState extends ConsumerState<CustomMixScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(customMixArithmeticProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          onPressed: () {
            HapticManager.instance.selectionClick();
            Navigator.pop(context);
          },
        ),
        title: Text(
          l10n.customMixArithmetic,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
            fontFamily: 'monospace',
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, size: 20, color: theme.colorScheme.primary),
            onPressed: () => _showHelp(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFullHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildSetupMode(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GlassmorphicContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        borderRadius: 12,
        child: Column(
          children: [
            Text(
              l10n.operationMatrix.toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 10,
                letterSpacing: 2,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.custom.toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w200,
                color: theme.colorScheme.onSurface,
                fontFamily: 'monospace',
                letterSpacing: 8,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: -0.2, end: 0),
    );
  }

  Widget _buildSetupMode(CustomMixArithmeticState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.gameMode.toUpperCase()),
        const SizedBox(height: 12),
        _buildModeSelector(state),
        const SizedBox(height: 24),
        _buildSectionHeader(l10n.selectOperation.toUpperCase()),
        const SizedBox(height: 12),
        _buildOperationsGrid(state),
        const SizedBox(height: 24),
        _buildSectionHeader(l10n.intensity.toUpperCase()),
        const SizedBox(height: 12),
        _buildDifficultySlider(state),
        const SizedBox(height: 32),
        PremiumPrimaryButton(
          text: l10n.initializeMix.toUpperCase(),
          onPressed: state.selectedOperations.isNotEmpty
              ? () {
                  ref.read(soundManagerProvider).playEffect('click');
                  HapticManager.instance.mediumImpact();
                  ref.read(customMixArithmeticProvider.notifier).startMix();
                  
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => GameScreen()),
                  );
                }
              : () {},
          icon: Icons.power_settings_new,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(width: 4, height: 12, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildModeSelector(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: CustomMixMode.values.map((mode) {
          final isSelected = state.mode == mode;
          return Expanded(
            child: InkWell(
              onTap: () {
                HapticManager.instance.selectionClick();
                ref.read(customMixArithmeticProvider.notifier).setMode(mode);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getModeIcon(mode),
                      size: 16,
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getModeName(mode).toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getModeName(CustomMixMode mode) {
    switch (mode) {
      case CustomMixMode.standard:
        return l10n.standard;
      case CustomMixMode.suddenDeath:
        return l10n.suddenDeath;
      case CustomMixMode.zen:
        return l10n.zen;
      case CustomMixMode.timeAttack:
        return l10n.timeAttack;
    }
  }

  IconData _getModeIcon(CustomMixMode mode) {
    switch (mode) {
      case CustomMixMode.standard: return Icons.settings_input_component;
      case CustomMixMode.suddenDeath: return Icons.bolt;
      case CustomMixMode.zen: return Icons.self_improvement;
      case CustomMixMode.timeAttack: return Icons.timer;
    }
  }

  Widget _buildOperationsGrid(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ArithmeticOperation.values.map((op) {
        final isSelected = state.selectedOperations.contains(op);
        return InkWell(
          onTap: () {
            HapticManager.instance.selectionClick();
            ref.read(customMixArithmeticProvider.notifier).toggleOperation(op);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: 200.ms,
            width: (MediaQuery.of(context).size.width - 48 - 36) / 4,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
          child: Center(
            child: _getOperationSymbol(op, isSelected: isSelected),
          ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySlider(CustomMixArithmeticState state) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.intensity.toUpperCase(),
                style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              Text(
                '${l10n.levelPrefix} ${state.selectedDifficulty}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: state.selectedDifficulty.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) {
              HapticManager.instance.lightImpact();
              ref.read(customMixArithmeticProvider.notifier).setDifficulty(v.round());
            },
          ),
        ],
      ),
    );
  }

  Widget _getOperationSymbol(ArithmeticOperation op, {bool isSelected = false}) {
    final theme = Theme.of(context);
    final style = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
    );
    switch (op) {
      case ArithmeticOperation.addition: return Text('+', style: style);
      case ArithmeticOperation.subtraction: return Text('-', style: style);
      case ArithmeticOperation.multiplication: return Text('×', style: style);
      case ArithmeticOperation.division: return Text('÷', style: style);
    }
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.modeProtocols.toUpperCase()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.standardDesc, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.suddenDeathDesc, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.zenDesc, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.timeAttackDesc, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.understood.toUpperCase()),
          ),
        ],
      ),
    );
  }
}
