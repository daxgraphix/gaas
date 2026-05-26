import 'package:flutter/material.dart';
import '../../core/sound_manager.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onClear;
  final VoidCallback onSubmit;
  final String currentInput;

  const CustomKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onClear,
    required this.onSubmit,
    required this.currentInput,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Answer display row - Minimalist thin line
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white24,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    currentInput.isEmpty ? '?' : currentInput,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticManager.lightImpact();
                  onClear();
                },
                icon: Icon(
                  Icons.backspace_outlined,
                   color: Colors.white70,
                ),
                iconSize: 20,
              ),
            ],
          ),
        ),
        _buildKeypad(context),
      ],
    );
  }

  Widget _buildKeypad(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(context, ['1', '2', '3']),
          _buildRow(context, ['4', '5', '6']),
          _buildRow(context, ['7', '8', '9']),
          Row(
            children: [
              Expanded(
                child: _buildActionKey(
                  context,
                  Icons.close,
                  () {
                    HapticManager.mediumImpact();
                    onClear();
                  },
                ),
              ),
              Expanded(child: _buildKey(context, '0')),
              Expanded(
                child: _buildActionKey(
                  context,
                  Icons.check,
                  () {
                    HapticManager.heavyImpact();
                    onSubmit();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      children: keys.map((k) {
        return Expanded(
          child: _buildKey(context, k),
        );
      }).toList(),
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    return SizedBox(
      height: 65,
      child: InkWell(
        onTap: () {
          HapticManager.selectionClick();
          onKeyPressed(key);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white10,
              width: 0.25,
            ),
          ),
          child: Center(
            child: Text(
              key,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w200,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 65,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white10,
              width: 0.25,
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}


class DisableKeyboard extends StatelessWidget {
  final Widget child;

  const DisableKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {},
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: child,
      ),
    );
  }
}
