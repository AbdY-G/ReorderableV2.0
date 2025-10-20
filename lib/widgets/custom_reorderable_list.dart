import 'dart:async';
import 'package:flutter/material.dart';

class CustomDraggableList extends StatefulWidget {
  final List<Widget> children;
  final Function(int oldIndex, int newIndex) onReorder;
  final Widget Function(Widget child, int index)? feedbackBuilder;
  final Color insertIndicatorColor;
  final double insertIndicatorHeight;
  final ScrollController? scrollController;

  const CustomDraggableList({
    super.key,
    required this.children,
    required this.onReorder,
    this.feedbackBuilder,
    this.insertIndicatorColor = Colors.purple,
    this.insertIndicatorHeight = 6.0,
    this.scrollController,
  });

  @override
  State<CustomDraggableList> createState() => _CustomDraggableListState();
}

class _CustomDraggableListState extends State<CustomDraggableList> {
  int? _targetIndex;
  Timer? _autoScrollTimer;
  double _autoScrollSpeed = 0.0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll(double speed) {
    _autoScrollSpeed = speed;
    _autoScrollTimer ??= Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      if (widget.scrollController != null &&
          widget.scrollController!.hasClients) {
        final currentOffset = widget.scrollController!.offset;
        final newOffset = currentOffset + _autoScrollSpeed;

        if (newOffset >= 0 &&
            newOffset <= widget.scrollController!.position.maxScrollExtent) {
          widget.scrollController!.jumpTo(newOffset);
        }
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _autoScrollSpeed = 0.0;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.scrollController == null ||
        !widget.scrollController!.hasClients) {
      return;
    }

    // Получаем размеры экрана
    final screenSize = MediaQuery.of(context).size;
    final globalPosition = details.globalPosition;

    const autoScrollZone = 100.0; // Увеличиваем зону автоскролла
    const maxScrollSpeed = 15.0; // Увеличиваем скорость скролла

    // Автоскролл вверх - когда курсор в верхней части экрана
    if (globalPosition.dy < autoScrollZone &&
        widget.scrollController!.offset > 0) {
      final speed =
          (autoScrollZone - globalPosition.dy) /
          autoScrollZone *
          maxScrollSpeed;
      _startAutoScroll(-speed);
    }
    // Автоскролл вниз - когда курсор в нижней части экрана
    else if (globalPosition.dy > screenSize.height - autoScrollZone &&
        widget.scrollController!.offset <
            widget.scrollController!.position.maxScrollExtent) {
      final speed =
          (globalPosition.dy - (screenSize.height - autoScrollZone)) /
          autoScrollZone *
          maxScrollSpeed;
      _startAutoScroll(speed);
    }
    // Остановить автоскролл
    else {
      _stopAutoScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Основные элементы списка
        ...widget.children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;

          return Column(
            children: [
              // Drop zone перед элементом
              _buildDropZone(index),
              // Сам элемент
              _buildDraggableItem(child, index),
            ],
          );
        }),
        // Drop zone после последнего элемента
        _buildDropZone(widget.children.length),
      ],
    );
  }

  Widget _buildDropZone(int index) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        final draggedIndex = details.data;
        // Запрещаем вставку перед самим собой и сразу после себя
        return draggedIndex != index && draggedIndex + 1 != index;
      },
      onAcceptWithDetails: (details) {
        final draggedIndex = details.data;
        widget.onReorder(draggedIndex, index);
        setState(() {
          _targetIndex = null;
        });
      },
      onMove: (details) {
        setState(() {
          _targetIndex = index;
        });
      },
      onLeave: (data) {
        setState(() {
          _targetIndex = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty && _targetIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 24,
          decoration: BoxDecoration(
            color: isActive
                ? widget.insertIndicatorColor.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedScale(
              scale: isActive ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: widget.insertIndicatorHeight,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.insertIndicatorColor,
                  borderRadius: BorderRadius.circular(
                    widget.insertIndicatorHeight / 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.insertIndicatorColor.withValues(
                        alpha: 0.5,
                      ),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(child: Container()),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(Widget child, int index) {
    return LongPressDraggable<int>(
      data: index,
      onDragStarted: () {
        // Drag started
      },
      onDragUpdate: _handleDragUpdate,
      onDragEnd: (details) {
        setState(() {
          _targetIndex = null;
        });
        _stopAutoScroll();
      },
      feedback: widget.feedbackBuilder?.call(child, index) ?? 
               _buildDefaultFeedback(child, index),
      childWhenDragging: AnimatedOpacity(
        opacity: 0.3,
        duration: const Duration(milliseconds: 200),
        child: AnimatedScale(
          scale: 0.95,
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
      ),
      child: child,
    );
  }

  Widget _buildDefaultFeedback(Widget child, int index) {
    return Transform.scale(
      scale: 0.8, // Уменьшаем размер
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.9, // Добавляем прозрачность
          child: Container(
            width: 250,
            constraints: const BoxConstraints(maxHeight: 100),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Dragging...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
