import 'package:flutter/material.dart';
import '../../core/themes/app_themes.dart';
import '../../l10n/generated/app_localizations.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  String _expression = '';
  String _display = '0';
  String _currentInput = '0';
  bool _shouldResetInput = false;
  final List<String> _historyList = [];
  final List<String> _memory = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculator),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppDesignTokens.neonCyan),
            onPressed: _showHistory,
            tooltip: l10n.calculationHistory,
          ),
          IconButton(
            icon: const Icon(Icons.memory, color: AppDesignTokens.neonCyan),
            onPressed: _showMemory,
            tooltip: l10n.memory,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppDesignTokens.techBlack,
                    AppDesignTokens.techGrey.withValues(alpha: 0.55),
                    AppDesignTokens.techBlack,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildDisplay(theme),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildKeypad(theme),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay(ThemeData theme) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      useFrostedEffect: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_historyList.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _historyList.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        entry,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppDesignTokens.neonCyan.withValues(alpha: 0.6),
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          if (_historyList.isNotEmpty) const SizedBox(height: 12),
          if (_expression.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppDesignTokens.neonCyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _expression,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppDesignTokens.neonCyan.withValues(alpha: 0.8),
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          if (_expression.isNotEmpty) const SizedBox(height: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _display,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppDesignTokens.neonCyan,
                  fontFamily: 'monospace',
                  shadows: [
                    Shadow(
                      color: AppDesignTokens.neonCyan.withValues(alpha: 0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 420),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildButton('C', theme, isOperator: true, isClear: true),
                  _buildButton('±', theme, isOperator: true),
                  _buildButton('%', theme, isOperator: true),
                  _buildButton('÷', theme, isOperator: true),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton('7', theme),
                  _buildButton('8', theme),
                  _buildButton('9', theme),
                  _buildButton('×', theme, isOperator: true),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton('4', theme),
                  _buildButton('5', theme),
                  _buildButton('6', theme),
                  _buildButton('−', theme, isOperator: true),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton('1', theme),
                  _buildButton('2', theme),
                  _buildButton('3', theme),
                  _buildButton('+', theme, isOperator: true),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildButton('0', theme, isWide: true),
                  ),
                  Expanded(
                    child: _buildButton('.', theme),
                  ),
                  Expanded(
                    child: _buildButton(l10n.del, theme, isOperator: true),
                  ),
                  Expanded(
                    child: _buildButton('=', theme, isEquals: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String label,
    ThemeData theme, {
    bool isOperator = false,
    bool isClear = false,
    bool isEquals = false,
    bool isWide = false,
  }) {
    final borderColor = isClear
        ? AppDesignTokens.neonPink
        : isEquals
            ? AppDesignTokens.neonCyan
            : isOperator
                ? AppDesignTokens.neonYellow
                : AppDesignTokens.neonCyan.withValues(alpha: 0.3);

    final textColor = isClear
        ? AppDesignTokens.neonPink
        : isEquals
            ? theme.colorScheme.onPrimary
            : isOperator
                ? AppDesignTokens.neonYellow
                : AppDesignTokens.neonCyan;

    return Expanded(
      flex: isWide ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: PremiumAnimatedButton(
          onPressed: () => _onButtonPressed(label),
          backgroundColor: isEquals ? AppDesignTokens.neonCyan : AppDesignTokens.techGrey,
          borderColor: borderColor,
          borderRadius: 8,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onButtonPressed(String value) {
    setState(() {
      switch (value) {
        case 'C':
          _clear();
          break;
        case '±':
          _toggleSign();
          break;
        case '%':
          _percentage();
          break;
        case '÷':
        case '×':
        case '−':
        case '+':
          _appendOperator(value);
          break;
        case '=':
          _calculate();
          break;
        case '.':
          _addDecimal();
          break;
        case 'DEL':
        case 'FUTA':
          _deleteLast();
          break;
        default:
          _appendDigit(value);
      }
    });
  }

  void _clear() {
    _expression = '';
    _display = '0';
    _currentInput = '0';
    _shouldResetInput = false;
  }

  void _toggleSign() {
    if (_currentInput == '0') return;
    if (_currentInput.startsWith('-')) {
      _currentInput = _currentInput.substring(1);
    } else {
      _currentInput = '-$_currentInput';
    }
    _display = _currentInput;
  }

  void _percentage() {
    final value = double.tryParse(_currentInput);
    if (value == null) return;
    final result = value / 100;
    _currentInput = _formatNumber(result);
    _display = _currentInput;
    _shouldResetInput = true;
  }

  void _appendOperator(String op) {
    if (_expression.contains('=')) {
      _expression = '$_currentInput $op';
      _shouldResetInput = true;
      return;
    }

    final components = _expression.trim().split(' ');
    final lastSegment = components.isNotEmpty ? components.last : '';
    if (_isOperator(lastSegment)) {
      _expression = _expression.trim().substring(0, _expression.trim().length - 1) + op;
      return;
    }

    if (_expression.isEmpty) {
      _expression = '$_currentInput $op';
    } else if (!_shouldResetInput) {
      _calculate();
      _expression = '$_currentInput $op';
    } else {
      _expression = '$_currentInput $op';
    }
    _shouldResetInput = true;
  }

  void _calculate() {
    if (_expression.isEmpty) return;
    if (_expression.contains('=')) return;

    final trimmed = _expression.trim();
    final parts = trimmed.split(' ');
    if (parts.length != 2) return;

    final left = parts[0];
    final op = parts[1];
    final right = _currentInput;
    final lhs = double.tryParse(left.replaceAll('−', '-'));
    final rhs = double.tryParse(right.replaceAll('−', '-'));
    if (lhs == null || rhs == null) {
      _display = 'Error';
      _shouldResetInput = true;
      return;
    }

    double result;
    switch (op) {
      case '+':
        result = lhs + rhs;
        break;
      case '−':
        result = lhs - rhs;
        break;
      case '×':
        result = lhs * rhs;
        break;
      case '÷':
        if (rhs == 0) {
          _display = l10n.divByZero;
          _shouldResetInput = true;
          return;
        }
        result = lhs / rhs;
        break;
      default:
        _display = 'Error';
        _shouldResetInput = true;
        return;
    }

    final formatted = _formatNumber(result);
    _expression = '$left $op $right =';
    _display = formatted;
    _currentInput = formatted;
    _shouldResetInput = true;

    _historyList.add('$_expression $formatted');
    if (_historyList.length > 15) {
      _historyList.removeAt(0);
    }
  }

  String _formatNumber(double number) {
    if (number.isInfinite || number.isNaN) {
      return 'Error';
    }
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    var result = number.toStringAsFixed(8);
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      if (result.endsWith('.')) {
        result = result.substring(0, result.length - 1);
      }
    }
    return result;
  }

  void _addDecimal() {
    if (_shouldResetInput) {
      _currentInput = '0.';
      _display = _currentInput;
      _shouldResetInput = false;
      return;
    }
    if (_currentInput.contains('.')) return;
    _currentInput = '$_currentInput.';
    _display = _currentInput;
  }

  void _deleteLast() {
    if (_shouldResetInput) {
      _clear();
      return;
    }

    if (_currentInput.length <= 1 || (_currentInput.length == 2 && _currentInput.startsWith('-'))) {
      _currentInput = '0';
    } else {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    }
    _display = _currentInput;
  }

  void _appendDigit(String digit) {
    if (_shouldResetInput || _currentInput == '0') {
      _currentInput = digit;
      _shouldResetInput = false;
    } else {
      _currentInput = '$_currentInput$digit';
    }
    _display = _currentInput;
  }

  bool _isOperator(String value) {
    return value == '+' || value == '−' || value == '×' || value == '÷';
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.calculationHistory,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (_historyList.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _historyList.clear());
                      Navigator.pop(context);
                    },
                    child: Text(l10n.clear),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_historyList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.noCalculationsYet,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_historyList[index]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMemory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.memory,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _memoryClear,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: Text(l10n.clear),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_memory.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.memoryIsEmpty,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _memory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_memory[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () => _memoryAdd(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () => _memorySubtract(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _memoryClear() {
    setState(() => _memory.clear());
    Navigator.pop(context);
  }

  void _memoryAdd(int index) {
    final current = double.tryParse(_currentInput) ?? 0;
    if (_memory.isEmpty || index < 0 || index >= _memory.length) {
      _memory.add(_currentInput);
      setState(() {});
      return;
    }
    final value = double.tryParse(_memory[index]) ?? 0;
    _memory[index] = _formatNumber(value + current);
    setState(() {});
  }

  void _memorySubtract(int index) {
    if (_memory.isEmpty || index < 0 || index >= _memory.length) return;
    final value = double.tryParse(_memory[index]) ?? 0;
    final current = double.tryParse(_currentInput) ?? 0;
    _memory[index] = _formatNumber(value - current);
    setState(() {});
  }
}
