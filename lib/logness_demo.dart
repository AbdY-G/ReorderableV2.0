import 'package:flutter/material.dart';
import 'widgets/custom_reorderable_list.dart';
import 'widgets/reorderable_list_config.dart';
import 'models/log.dart';
import 'blocks/text_block.dart';
import 'blocks/image_block.dart';
import 'blocks/audio_block.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogNessDemo(),
    ));

class LogNessDemo extends StatefulWidget {
  const LogNessDemo({super.key});

  @override
  State<LogNessDemo> createState() => _LogNessDemoState();
}

class _LogNessDemoState extends State<LogNessDemo> {
  List<Log> logs = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Создаем тестовые данные
    logs = [
      Log.text(
        id: '1',
        content: 'Это текстовый лог с важной информацией о процессе разработки приложения.',
        title: 'Разработка',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Log.image(
        id: '2',
        imageUrl: 'assets/image1.jpg',
        caption: 'Скриншот интерфейса приложения',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Log.audio(
        id: '3',
        audioUrl: 'assets/audio1.mp3',
        title: 'Запись встречи',
        duration: const Duration(minutes: 15, seconds: 42),
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Log.text(
        id: '4',
        content: 'Длинный текст с подробным описанием архитектуры системы и принципов работы.',
        title: 'Архитектура',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      Log.image(
        id: '5',
        imageUrl: 'assets/image2.jpg',
        caption: 'Диаграмма базы данных',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Log.audio(
        id: '6',
        audioUrl: 'assets/audio2.mp3',
        title: 'Интервью с пользователем',
        duration: const Duration(minutes: 8, seconds: 15),
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      // Добавляем больше элементов для тестирования скролла
      Log.text(
        id: '7',
        content: 'Дополнительный текстовый блок для демонстрации скролла.',
        title: 'Тест скролла',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Log.image(
        id: '8',
        imageUrl: 'assets/image3.jpg',
        caption: 'Еще один скриншот',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Log.audio(
        id: '9',
        audioUrl: 'assets/audio3.mp3',
        title: 'Дополнительная запись',
        duration: const Duration(minutes: 5, seconds: 30),
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      Log.text(
        id: '10',
        content: 'Последний элемент списка для демонстрации полного функционала.',
        title: 'Финал',
        timestamp: DateTime.now(),
      ),
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildLogWidget(Log log) {
    switch (log.blockType) {
      case BlockType.text:
        return TextBlock(
          content: log.content,
          title: log.title,
          timestamp: log.timestamp,
        );
      case BlockType.image:
        return ImageBlock(
          imageUrl: log.content,
          caption: log.caption,
          timestamp: log.timestamp,
        );
      case BlockType.audio:
        return AudioBlock(
          audioUrl: log.content,
          title: log.title,
          duration: log.duration,
          timestamp: log.timestamp,
        );
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Log item = logs.removeAt(oldIndex);
      logs.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomDraggableList<Log>(
        items: logs,
        itemBuilder: (log, index) => _buildLogWidget(log),
        onReorder: _onReorder,
        scrollController: _scrollController,
            config: const ReorderableListConfig(
              insertIndicatorColor: Colors.orange,
              insertIndicatorHeight: 6.0,
              feedbackScale: 0.7,
              feedbackOpacity: 0.9,
              selectedWidgetScale: 0.95,
              selectedWidgetOpacity: 0.7,
              autoScrollZone: 100.0,
              maxScrollSpeed: 15.0,
              topPadding: 0.0, // Можно настроить верхний отступ (по умолчанию 0)
              bottomPadding: 80.0,
            ),
        feedbackBuilder: (log, index) {
          // Создаем уменьшенную копию виджета для feedback
          return Transform.scale(
            scale: 0.7, // Уменьшаем размер (можно использовать config.feedbackScale)
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              child: Opacity(
                opacity: 0.9, // Добавляем прозрачность (можно использовать config.feedbackOpacity)
                child: _buildLogWidget(log),
              ),
            ),
          );
        },
      ),
    );
  }
}
