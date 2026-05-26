import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/generated/app_localizations.dart';

class LanguageSwitcher extends ConsumerWidget {
  final bool showText;
  final double size;

  const LanguageSwitcher({
    super.key,
    this.showText = true,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).toggleLanguage();
        // Show feedback
        final newLocale = ref.read(localeProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.language ?? 'Language'} → ${newLocale.name}'),
            duration: const Duration(seconds: 1),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLocale.flag,
              style: TextStyle(fontSize: size),
            ),
            if (showText) ...[
              const SizedBox(width: 4),
              Text(
                currentLocale.nativeName,
                style: TextStyle(
                  fontSize: size - 4,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.swap_horiz,
              size: size - 4,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// Quick language toggle button for app bars
class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return IconButton(
      icon: Text(
        currentLocale.flag,
        style: const TextStyle(fontSize: 20),
      ),
      tooltip: 'Switch Language (${currentLocale.name})',
      onPressed: () {
        ref.read(localeProvider.notifier).toggleLanguage();
        final newLocale = ref.read(localeProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${newLocale.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}