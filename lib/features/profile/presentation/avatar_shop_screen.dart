import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../l10n/generated/app_localizations.dart';

class AvatarShopScreen extends ConsumerWidget {
  const AvatarShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userSessionProvider);
    final l10n = AppLocalizations.of(context)!;

    if (user == null) return const Scaffold();

    final theme = Theme.of(context);
    final totalStars = ref.watch(totalStarsProvider).value ?? 0;

    final availableAvatars = [
      {'id': 'circle', 'name': 'Circle', 'cost': 0, 'icon': Icons.circle, 'rarity': 'common', 'effect': 'None'},
      {'id': 'square', 'name': 'Square', 'cost': 0, 'icon': Icons.square, 'rarity': 'common', 'effect': 'None'},
      {'id': 'star', 'name': 'Star', 'cost': 0, 'icon': Icons.star, 'rarity': 'common', 'effect': 'None'},
      {'id': 'diamond', 'name': 'Diamond', 'cost': 500, 'icon': Icons.diamond, 'rarity': 'rare', 'effect': 'Glitter'},
      {'id': 'shield', 'name': 'Shield', 'cost': 1000, 'icon': Icons.shield, 'rarity': 'epic', 'effect': 'Shield Aura'},
      {'id': 'crown', 'name': 'Crown', 'cost': 2500, 'icon': Icons.emoji_events, 'rarity': 'legendary', 'effect': 'Royal Glow'},
      {'id': 'ninja', 'name': 'Ninja', 'cost': 5000, 'icon': Icons.sports_martial_arts, 'rarity': 'epic', 'effect': 'Stealth'},
      {'id': 'rocket', 'name': 'Rocket', 'cost': 10000, 'icon': Icons.rocket_launch, 'rarity': 'legendary', 'effect': 'Rocket Trail'},
      {'id': 'dragon', 'name': 'Dragon', 'cost': 20000, 'icon': Icons.local_fire_department, 'rarity': 'mythic', 'effect': 'Fire Breath'},
      {'id': 'phoenix', 'name': 'Phoenix', 'cost': 50000, 'icon': Icons.mood, 'rarity': 'mythic', 'effect': 'Rebirth Flame'},
    ];

    final lockedCount = availableAvatars.where((a) => (a['cost'] as int) > user.totalPoints).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.08),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, user, theme, l10n, lockedCount, totalStars),
                Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: availableAvatars.length,
                    itemBuilder: (context, index) {
                      final avatar = availableAvatars[index];
                      return _buildAvatarCard(context, ref, user, avatar, theme, l10n);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, ThemeData theme, AppLocalizations l10n, int lockedCount, int totalStars) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: theme.colorScheme.onSurface,
                    size: 16,
                  ),
                ),
                onPressed: () {
                  HapticManager.instance.selectionClick();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVATAR SHOP'.toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$lockedCount locked • $totalStars stars collected',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPointsCounter(user, theme),
            ],
          ),
          const SizedBox(height: 16),
          _buildStarsProgressBar(context, user, totalStars, theme),
        ],
      ),
    );
  }

  Widget _buildPointsCounter(dynamic user, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: theme.colorScheme.onPrimary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '${user?.totalPoints ?? 0}',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildStarsProgressBar(BuildContext context, dynamic user, int totalStars, ThemeData theme) {
    final progress = (totalStars / 30).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AVATAR UNLOCKS',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              height: 12,
              width: MediaQuery.of(context).size.width * 0.7 * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.tertiary,
                    theme.colorScheme.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarCard(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    Map<String, dynamic> avatar,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final isUnlocked =
        (user.unlockedAvatars ?? []).contains(avatar['id'] as String) ||
        (avatar['cost'] as int) == 0;
    final isEquipped = user.avatarShape == avatar['id'];
    final cost = avatar['cost'] as int;
    final canAfford = (user.totalPoints ?? 0) >= cost;

    return GestureDetector(
      onTap: isUnlocked && !isEquipped
          ? () {
              HapticManager.instance.selectionClick();
              ref.read(userSessionProvider.notifier).equipAvatar(avatar['id'] as String);
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: isEquipped
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.secondary.withValues(alpha: 0.15),
                  ],
                )
              : null,
          border: Border.all(
            color: isEquipped
                ? theme.colorScheme.primary
                : isUnlocked
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isEquipped
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _getAvatarGradient(avatar['rarity'] as String, theme),
                          ),
                          boxShadow: isEquipped
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          avatar['icon'] as IconData,
                          size: 36,
                          color: isEquipped
                              ? theme.colorScheme.onPrimary
                              : isUnlocked
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                                  : Colors.white24,
                        ),
                      ),
                      if (!isUnlocked)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                            child: const Icon(Icons.lock, size: 24, color: Colors.white38),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (avatar['name'] as String).toUpperCase(),
                    style: TextStyle(
                      color: isEquipped
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRarityBadgeColor(avatar['rarity'] as String, theme),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (avatar['rarity'] as String).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (cost > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? theme.colorScheme.primary.withValues(alpha: 0.2)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        canAfford ? '$cost pts' : 'UNLOCK',
                        style: TextStyle(
                          color: canAfford
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isEquipped)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'EQUIPPED',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    avatar['effect'] as String,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }

  List<Color> _getAvatarGradient(String rarity, ThemeData theme) {
    switch (rarity) {
      case 'common':
        return [theme.colorScheme.surface, theme.colorScheme.surface.withValues(alpha: 0.7)];
      case 'rare':
        return [theme.colorScheme.primary, theme.colorScheme.secondary];
      case 'epic':
        return [theme.colorScheme.tertiary, theme.colorScheme.primary];
      case 'legendary':
        return [theme.colorScheme.tertiary, theme.colorScheme.secondary];
      case 'mythic':
        return [theme.colorScheme.inversePrimary, theme.colorScheme.error];
      default:
        return [theme.colorScheme.surface, theme.colorScheme.surface.withValues(alpha: 0.7)];
    }
  }

  Color _getRarityBadgeColor(String rarity, ThemeData theme) {
    switch (rarity) {
      case 'common':
        return theme.colorScheme.onSurface.withValues(alpha: 0.3);
      case 'rare':
        return theme.colorScheme.primary;
      case 'epic':
        return theme.colorScheme.tertiary;
      case 'legendary':
        return theme.colorScheme.tertiary;
      case 'mythic':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface.withValues(alpha: 0.3);
    }
  }
}
