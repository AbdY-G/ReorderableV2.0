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
  final Offset feedbackOffset;

  const CustomDraggableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.feedbackBuilder,
    this.insertIndicatorColor = Colors.purple,
    this.insertIndicatorHeight = 6.0,
    this.scrollController,
    this.feedbackOffset = const Offset(0, -50), // По умолчанию смещение вверх
  });

  @override
  State<CustomDraggableList<T>> createState() => _CustomDraggableListState<T>();
}

class _CustomDraggableListState<T> extends State<CustomDraggableList<T>> {
  int? _targetIndex;
  Timer? _autoScrollTimer;
  double _autoScrollSpeed = 0.0;
  Offset? _dragStartPosition;
  OverlayEntry? _feedbackOverlay;
  bool _isDragging = false;
  T? _draggedItem;
  int? _draggedIndex;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _feedbackOverlay?.remove();
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

  void _showFeedbackOverlay(T item, Widget child, int index, Offset position) {
    print('_showFeedbackOverlay called with position: $position');
    _feedbackOverlay?.remove();
    
    _feedbackOverlay = OverlayEntry(
      builder: (context) {
        print('OverlayEntry builder called');
        return Positioned(
          left: position.dx - 50, // Центрируем по горизонтали
          top: position.dy + 20,  // Размещаем под пальцем
          child: Container(
            width: 200,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'FEEDBACK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
    
    print('Inserting overlay into Overlay.of(context)');
    Overlay.of(context).insert(_feedbackOverlay!);
    print('Overlay inserted successfully');
  }

  void _hideFeedbackOverlay() {
    _feedbackOverlay?.remove();
    _feedbackOverlay = null;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.scrollController == null ||
        !widget.scrollController!.hasClients) {
      return;
    }

    // Получаем размеры экрана
    final screenSize = MediaQuery.of(context).size;
    final globalPosition = details.globalPosition;

    // Обновляем позицию overlay если он активен
    if (_isDragging && _feedbackOverlay != null) {
      _feedbackOverlay!.remove();
      _feedbackOverlay = OverlayEntry(
        builder: (context) => Positioned(
          left: globalPosition.dx - 50, // Центрируем по горизонтали
          top: globalPosition.dy + 20,  // Размещаем под пальцем
          child: Container(
            width: 200,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'FEEDBACK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_feedbackOverlay!);
    }

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
    return GestureDetector(
      onTapDown: (details) {
        print('onTapDown called with position: ${details.globalPosition}');
        _dragStartPosition = details.globalPosition;
        // Не устанавливаем _isDragging здесь, так как это еще не drag
        _draggedItem = item;
        _draggedIndex = index;
      },
      child: LongPressDraggable<int>(
        data: index,
        onDragStarted: () {
          print('onDragStarted called');
          _isDragging = true;
          // Показываем overlay с позицией из onTapDown
          if (_dragStartPosition != null) {
            _showFeedbackOverlay(item, child, index, _dragStartPosition!);
          }
        },
        onDragUpdate: (details) {
          print('onDragUpdate called with position: ${details.globalPosition}');
          // Обновляем позицию пальца
          _dragStartPosition = details.globalPosition;
          
          // Обновляем позицию overlay
          if (_isDragging && _feedbackOverlay != null) {
            _feedbackOverlay!.remove();
            _feedbackOverlay = OverlayEntry(
              builder: (context) => Positioned(
                left: details.globalPosition.dx - 50, // Центрируем по горизонтали
                top: details.globalPosition.dy + 20,  // Размещаем под пальцем
                child: Container( // Simplified feedback for debugging
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'FEEDBACK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
            Overlay.of(context).insert(_feedbackOverlay!);
          }
          
          _handleDragUpdate(details);
        },
        onDragEnd: (details) {
          print('onDragEnd called');
          setState(() {
            _targetIndex = null;
            _dragStartPosition = null;
            _isDragging = false;
            _draggedItem = null;
            _draggedIndex = null;
          });
          _hideFeedbackOverlay();
          _stopAutoScroll();
        },
        feedback: Container(), // Пустой feedback, используем overlay
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
      ),
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
