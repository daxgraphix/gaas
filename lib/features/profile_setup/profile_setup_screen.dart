import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../home/presentation/home_screen.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final bool isInitialSetup;

  const ProfileSetupScreen({super.key, this.isInitialSetup = false});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final _nameController = TextEditingController();
  String _selectedShape = 'circle';
  int _selectedColorIndex = 0;
  bool _isSaving = false;

  final List<String> _shapes = [
    'circle',
    'square',
    'triangle',
    'star',
    'diamond',
  ];
  final List<Color> _avatarColors = [
    const Color(0xFF6366F1),
    const Color(0xFF22D3EE),
    const Color(0xFFF472B6),
    const Color(0xFF22C55E),
    const Color(0xFFFACC15),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userSessionProvider);
      if (user != null) {
        _nameController.text = user.name;
        setState(() {
          _selectedShape = user.avatarShape;
          try {
            final color = user.avatarColor.startsWith('#')
                ? Color(int.parse(user.avatarColor.replaceFirst('#', '0xFF')))
                : Color(int.parse(user.avatarColor));
            final index = _avatarColors.indexWhere((c) => c.toARGB32() == color.toARGB32());
            if (index != -1) _selectedColorIndex = index;
          } catch (e) {
            // Default to first color if parsing fails
            _selectedColorIndex = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterYourName)));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(userSessionProvider.notifier)
          .updateUser(
            name: name,
            avatarShape: _selectedShape,
            avatarColor: '#${_avatarColors[_selectedColorIndex].toARGB32().toRadixString(16).toUpperCase()}',
          );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_customization', true);

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorSavingProfile}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.15),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  widget.isInitialSetup ? l10n.welcomeExclamation : l10n.editProfile,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isInitialSetup
                      ? l10n.letsSetupYourProfile
                      : l10n.customizeYourProfile,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
                _buildAvatarPreview(theme),
                const SizedBox(height: 32),
                _buildNameInput(theme),
                const SizedBox(height: 24),
                _buildShapeSelector(theme),
                const SizedBox(height: 24),
                _buildColorSelector(theme),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.isInitialSetup ? l10n.getStarted : l10n.save,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(ThemeData theme) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _avatarColors[_selectedColorIndex],
        boxShadow: [
          BoxShadow(
            color: _avatarColors[_selectedColorIndex].withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getAvatarIcon(_selectedShape),
          size: 70,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNameInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.yourName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: l10n.enterYourName,
            prefixIcon: const Icon(Icons.person_outline),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShapeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.avatarShape,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _shapes.map((shape) {
            final isSelected = _selectedShape == shape;
            return GestureDetector(
              onTap: () => setState(() => _selectedShape = shape),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _getAvatarIcon(shape),
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.avatarColor,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(_avatarColors.length, (index) {
            final isSelected = _selectedColorIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedColorIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _avatarColors[index],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _avatarColors[index].withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  IconData _getAvatarIcon(String shape) {
    switch (shape) {
      case 'circle':
        return Icons.circle;
      case 'square':
        return Icons.square;
      case 'triangle':
        return Icons.change_history;
      case 'star':
        return Icons.star;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.circle;
    }
  }
}
