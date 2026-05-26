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
      {'id': 'circle', 'name': 'Circle', 'cost': 0, 'icon': Icons.circle},
      {'id': 'square', 'name': 'Square', 'cost': 0, 'icon': Icons.square},
      {'id': 'star', 'name': 'Star', 'cost': 0, 'icon': Icons.star},
      {'id': 'diamond', 'name': 'Diamond', 'cost': 500, 'icon': Icons.diamond},
      {'id': 'shield', 'name': 'Shield', 'cost': 1000, 'icon': Icons.shield},
      {
        'id': 'crown',
        'name': 'Crown',
        'cost': 5000,
        'icon': Icons.emoji_events,
      },
      {
        'id': 'ninja',
        'name': 'Ninja',
        'cost': 10000,
        'icon': Icons.sports_martial_arts,
      },
      {
        'id': 'rocket',
        'name': 'Rocket',
        'cost': 15000,
        'icon': Icons.rocket_launch,
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, user, theme),
            Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), height: 1, thickness: 0.5),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
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

  Widget _buildHeader(BuildContext context, dynamic user, ThemeData theme) {
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
              HapticManager.selectionClick();
              Navigator.pop(context);
            },
          ),
           Expanded(
             child: Text(
               'AVATAR SHOP',
               style: TextStyle(
                 color: theme.colorScheme.onSurface,
                 fontSize: 14,
                 letterSpacing: 2,
                 fontWeight: FontWeight.w300,
               ),
               textAlign: TextAlign.center,
             ),
           ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Icon(
                  Icons.stars_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${user.totalPoints}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w200,
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

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isEquipped ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            avatar['icon'] as IconData,
            size: 48,
            color: isEquipped
                ? theme.colorScheme.primary
                : (isUnlocked ? theme.colorScheme.onSurface.withValues(alpha: 0.7) : theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          const SizedBox(height: 16),
          Text(
            (avatar['name'] as String).toUpperCase(),
            style: TextStyle(
              color: isEquipped ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16),
          if (isEquipped)
            Text(
              l10n.equipped,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.w300,
              ),
            )
           else if (isUnlocked)
             _buildMinimalButton(
               context,
               label: 'EQUIP',
               onPressed: () {
                 HapticManager.selectionClick();
                 ref
                     .read(userSessionProvider.notifier)
                     .updateUser(avatarShape: avatar['id'] as String);
               },
             )
           else
             _buildMinimalButton(
               context,
               label: '$cost',
               onPressed: () {
                 HapticManager.selectionClick();
                 _buyAvatar(context, ref, user, avatar['id'] as String, cost);
               },
               isAction: true,
            ),
        ],
      ),
    );
  }

  Widget _buildMinimalButton(BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    bool isAction = false,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isAction ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 0.5,
          ),
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isAction ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 10,
            letterSpacing: 1,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  void _buyAvatar(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    String avatarId,
    int cost,
  ) async {
    if (user.totalPoints < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough points! Keep playing to earn more.'),
        ),
      );
      return;
    }

    final success = await ref
        .read(userSessionProvider.notifier)
        .unlockAvatar(avatarId, cost);
    if (success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Avatar unlocked!')));
    }
  }
}
