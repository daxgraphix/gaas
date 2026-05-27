import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final availableAvatars = [
      {'id': 'circle', 'name': 'Circle', 'cost': 0, 'icon': Icons.circle, 'description': 'Default avatar'},
      {'id': 'square', 'name': 'Square', 'cost': 0, 'icon': Icons.square, 'description': 'Default avatar'},
      {'id': 'star', 'name': 'Star', 'cost': 0, 'icon': Icons.star, 'description': 'Default avatar'},
      {'id': 'diamond', 'name': 'Diamond', 'cost': 500, 'icon': Icons.diamond, 'description': 'Premium avatar'},
      {'id': 'shield', 'name': 'Shield', 'cost': 1000, 'icon': Icons.shield, 'description': 'Knight avatar'},
      {'id': 'crown', 'name': 'Crown', 'cost': 2500, 'icon': Icons.emoji_events, 'description': 'Royal avatar'},
      {'id': 'ninja', 'name': 'Ninja', 'cost': 5000, 'icon': Icons.sports_martial_arts, 'description': 'Stealth avatar'},
      {'id': 'rocket', 'name': 'Rocket', 'cost': 10000, 'icon': Icons.rocket_launch, 'description': 'Space avatar'},
      {'id': 'dragon', 'name': 'Dragon', 'cost': 20000, 'icon': Icons.local_fire_department, 'description': 'Legendary avatar'},
      {'id': 'phoenix', 'name': 'Phoenix', 'cost': 50000, 'icon': Icons.mood, 'description': 'Mythical avatar'},
    ];

    final lockedCount = availableAvatars.where((a) => (a['cost'] as int) > user.totalPoints).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, user, theme, l10n, lockedCount),
            Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), height: 1, thickness: 0.5),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
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
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, ThemeData theme, AppLocalizations l10n, int lockedCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
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
                  'AVATAR SHOP',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  '$lockedCount locked • ${(user?.totalPoints ?? 0)} points',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.stars_outlined,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${user?.totalPoints ?? 0}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          border: Border.all(
            color: isEquipped
                ? theme.colorScheme.primary
                : isUnlocked
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isEquipped
                          ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                          : isUnlocked
                              ? [theme.colorScheme.onSurface.withValues(alpha: 0.2), theme.colorScheme.surface]
                              : [theme.colorScheme.surface.withValues(alpha: 0.3), theme.colorScheme.surface],
                    ),
                  ),
                  child: Icon(
                    avatar['icon'] as IconData,
                    size: 32,
                    color: isEquipped
                        ? theme.colorScheme.onPrimary
                        : isUnlocked
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                            : Colors.white10,
                  ),
                ),
                if (!isUnlocked && !isEquipped)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      child: const Icon(Icons.lock, size: 20, color: Colors.white38),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              (avatar['name'] as String).toUpperCase(),
              style: TextStyle(
                color: isEquipped
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (cost > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: canAfford
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$cost',
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
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'EQUIPPED',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  }
