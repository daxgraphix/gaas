import 'package:flutter/material.dart';

class MathManipulativesWidget extends StatefulWidget {
  final int targetNumber;
  final Function(int) onComplete;

  const MathManipulativesWidget({
    super.key,
    required this.targetNumber,
    required this.onComplete,
  });

  @override
  State<MathManipulativesWidget> createState() => _MathManipulativesWidgetState();
}

class _MathManipulativesWidgetState extends State<MathManipulativesWidget> {
  final List<Offset> _objectPositions = [];
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with some objects
    for (int i = 0; i < 20; i++) {
      _objectPositions.add(Offset(50 + (i % 5) * 60, 100 + (i ~/ 5) * 60));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Count to ${widget.targetNumber} by dragging objects to the box',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Target box
                Positioned(
                  right: 20,
                  top: 50,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _currentCount == widget.targetNumber
                          ? Colors.green.withValues(alpha: 0.3)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: _currentCount == widget.targetNumber
                            ? Colors.green
                            : theme.colorScheme.primary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$_currentCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _currentCount == widget.targetNumber
                              ? Colors.green
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Draggable objects
                ..._objectPositions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final position = entry.value;
                  final isInBox = _isInBox(position);

                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: Draggable<int>(
                      data: index,
                      feedback: _buildObject(true),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: _buildObject(false),
                      ),
                      onDragEnd: (details) {
                        setState(() {
                          if (_isInBox(details.offset)) {
                            if (!isInBox) _currentCount++;
                          } else {
                            if (isInBox) _currentCount--;
                          }
                          _objectPositions[index] = details.offset;

                          if (_currentCount == widget.targetNumber) {
                            widget.onComplete(_currentCount);
                          }
                        });
                      },
                      child: _buildObject(false),
                    ),
                  );
                }),

                // Drag target
                Positioned(
                  right: 20,
                  top: 50,
                  child: DragTarget<int>(
                    onAcceptWithDetails: (details) {
                      // Handle drop in box
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: candidateData.isNotEmpty
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      );
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

  Widget _buildObject(bool isDragging) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue : Colors.red,
        shape: BoxShape.circle,
        boxShadow: isDragging ? [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: const Icon(
        Icons.circle,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  bool _isInBox(Offset position) {
    // Check if position is within the box area (right: 20-100, top: 50-130)
    return position.dx >= MediaQuery.of(context).size.width - 120 &&
           position.dx <= MediaQuery.of(context).size.width - 20 &&
           position.dy >= 50 && position.dy <= 130;
  }
}