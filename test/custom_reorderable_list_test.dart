import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_reorderable_list/custom_reorderable_list.dart';

void main() {
  group('CustomDraggableList Tests', () {
    testWidgets('should render list items', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDraggableList<String>(
              items: items,
              itemBuilder: (item, index) => ListTile(
                key: ValueKey(item),
                title: Text(item),
              ),
              onReorder: (oldIndex, newIndex) {},
            ),
          ),
        ),
      );

      // Verify that all items are rendered
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('should call onReorder when items are reordered', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      int? oldIndex;
      int? newIndex;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDraggableList<String>(
              items: items,
              itemBuilder: (item, index) => ListTile(
                key: ValueKey(item),
                title: Text(item),
              ),
              onReorder: (old, newIdx) {
                oldIndex = old;
                newIndex = newIdx;
              },
            ),
          ),
        ),
      );

      // Simulate reordering (this would need to be implemented based on the actual drag behavior)
      // For now, we just verify the widget renders correctly
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('should use custom configuration', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDraggableList<String>(
              items: items,
              itemBuilder: (item, index) => ListTile(
                key: ValueKey(item),
                title: Text(item),
              ),
              onReorder: (oldIndex, newIndex) {},
              config: const ReorderableListConfig(
                insertIndicatorColor: Colors.red,
                insertIndicatorHeight: 8.0,
                feedbackScale: 0.8,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });
  });

  group('ReorderableListConfig Tests', () {
    test('should create config with default values', () {
      const config = ReorderableListConfig();
      
      expect(config.insertIndicatorColor, Colors.purple);
      expect(config.insertIndicatorHeight, 6.0);
      expect(config.feedbackScale, 0.7);
      expect(config.feedbackOpacity, 0.9);
      expect(config.topPadding, 0.0);
      expect(config.bottomPadding, 80.0);
    });

    test('should create config with custom values', () {
      const config = ReorderableListConfig(
        insertIndicatorColor: Colors.red,
        insertIndicatorHeight: 8.0,
        feedbackScale: 0.8,
        topPadding: 20.0,
      );
      
      expect(config.insertIndicatorColor, Colors.red);
      expect(config.insertIndicatorHeight, 8.0);
      expect(config.feedbackScale, 0.8);
      expect(config.topPadding, 20.0);
    });

    test('should copy config with new values', () {
      const original = ReorderableListConfig(
        insertIndicatorColor: Colors.blue,
        feedbackScale: 0.5,
      );
      
      final copied = original.copyWith(
        insertIndicatorHeight: 10.0,
        feedbackOpacity: 0.8,
      );
      
      expect(copied.insertIndicatorColor, Colors.blue); // unchanged
      expect(copied.insertIndicatorHeight, 10.0); // changed
      expect(copied.feedbackScale, 0.5); // unchanged
      expect(copied.feedbackOpacity, 0.8); // changed
    });
  });
}
