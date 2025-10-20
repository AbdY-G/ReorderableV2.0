import 'dart:async';
import 'package:flutter/material.dart';

class CustomDraggableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final Function(int oldIndex, int newIndex) onReorder;
  final Widget Function(T item, int index)? feedbackBuilder;
  final Color insertIndicatorColor;
  final double insertIndicatorHeight;
  final ScrollController? scrollController;

  const CustomDraggableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.feedbackBuilder,
    this.insertIndicatorColor = Colors.purple,
    this.insertIndicatorHeight = 6.0,
    this.scrollController,
  });

  @override
  State<CustomDraggableList<T>> createState() => _CustomDraggableListState<T>();
}

class _CustomDraggableListState<T> extends State<CustomDraggableList<T>> {
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
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        children: [
          // Основные элементы списка
          ...widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final child = widget.itemBuilder(item, index);

            return Column(
              children: [
                // Drop zone перед элементом
                _buildDropZone(index),
                // Сам элемент
                _buildDraggableItem(item, child, index),
              ],
            );
          }),
          // Drop zone после последнего элемента
          _buildDropZone(widget.items.length),
        ],
      ),
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

  Widget _buildDraggableItem(T item, Widget child, int index) {
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
      feedback: widget.feedbackBuilder?.call(item, index) ?? 
               _buildDefaultFeedback(item, child, index),
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

  Widget _buildDefaultFeedback(T item, Widget child, int index) {
    return Transform.scale(
      scale: 0.8, // Уменьшаем размер
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.9, // Добавляем прозрачность
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 300,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: child, // Используем оригинальный виджет
            ),
          ),
        ),
      ),
    );
  }
}
