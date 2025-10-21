import 'dart:async';
import 'package:flutter/material.dart';
import 'reorderable_list_config.dart';

class CustomDraggableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final Function(int oldIndex, int newIndex) onReorder;
  final Widget Function(T item, int index)? feedbackBuilder;
  final ScrollController? scrollController;
  final ReorderableListConfig config;

  const CustomDraggableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.feedbackBuilder,
    this.scrollController,
    this.config = const ReorderableListConfig(),
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
  Offset _feedbackPosition = Offset.zero;

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
    
    // Обновляем позицию
    _feedbackPosition = position;
    
    // Если overlay уже существует, просто обновляем его позицию
    if (_feedbackOverlay != null) {
      _feedbackOverlay!.markNeedsBuild();
      return;
    }
    
          _feedbackOverlay = OverlayEntry(
            builder: (context) {
              print('OverlayEntry builder called');
              return Positioned(
                left: _feedbackPosition.dx - (widget.config.feedbackMaxWidth / 2), // Центрируем по горизонтали
                top: _feedbackPosition.dy - (widget.config.feedbackMaxHeight / 2),   // Центрируем по вертикали
                child: IgnorePointer(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: widget.config.feedbackMaxWidth,
                      maxHeight: widget.config.feedbackMaxHeight,
                    ),
                    child: widget.feedbackBuilder != null 
                      ? widget.feedbackBuilder!(item, index)
                      : Container(
                          width: 200,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
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

    // Позиция вставки определяется через DragTarget onMove, здесь не нужно ничего делать

        final autoScrollZone = widget.config.autoScrollZone;
        final maxScrollSpeed = widget.config.maxScrollSpeed;

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
        print('DragTarget onMove called for index $index');
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
          duration: widget.config.animationDuration,
          height: 12,
          decoration: BoxDecoration(
            color: isActive
                ? widget.config.insertIndicatorColor.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: widget.config.animationDuration,
            child: AnimatedScale(
              scale: isActive ? 1.0 : 0.8,
              duration: widget.config.animationDuration,
              child: Container(
                height: widget.config.insertIndicatorHeight,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.config.insertIndicatorColor,
                  borderRadius: BorderRadius.circular(
                    widget.config.insertIndicatorHeight / 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.config.insertIndicatorColor.withValues(
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
    final isSelected = _isDragging && _draggedIndex == index;
    
    return GestureDetector(
      onTapDown: (details) {
        print('onTapDown called with position: ${details.globalPosition}');
        _dragStartPosition = details.globalPosition;
        // Не устанавливаем _isDragging здесь, так как это еще не drag
        _draggedItem = item;
        _draggedIndex = index;
      },
      child: AnimatedScale(
        scale: isSelected ? widget.config.selectedWidgetScale : 1.0,
        duration: widget.config.animationDuration,
        child: AnimatedOpacity(
          opacity: isSelected ? widget.config.selectedWidgetOpacity : 1.0,
          duration: widget.config.animationDuration,
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
          
          // Обновляем позицию overlay во время перетаскивания
          if (_isDragging && _draggedItem != null && _draggedIndex != null) {
            _showFeedbackOverlay(_draggedItem!, child, _draggedIndex!, details.globalPosition);
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
        ),
      ),
    );
  }

}
