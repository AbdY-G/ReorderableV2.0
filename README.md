# Custom Reorderable List

A highly customizable reorderable list widget for Flutter with advanced drag-and-drop functionality, visual feedback, and auto-scrolling capabilities.

## Features

- 🎯 **Highly Customizable** - Configure colors, sizes, animations, and behavior
- 🖱️ **Smooth Drag & Drop** - Fluid drag-and-drop with visual feedback
- 📱 **Auto-scrolling** - Automatic scrolling when dragging near edges
- 🎨 **Visual Feedback** - Customizable feedback widget during drag
- 📏 **Flexible Sizing** - Support for items of varying sizes
- 🔧 **Easy Integration** - Simple API with sensible defaults

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  custom_reorderable_list: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:custom_reorderable_list/custom_reorderable_list.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> items = ['Item 1', 'Item 2', 'Item 3'];
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomDraggableList<String>(
        items: items,
        itemBuilder: (item, index) => ListTile(
          title: Text(item),
          leading: Icon(Icons.drag_handle),
        ),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
          });
        },
        scrollController: _scrollController,
      ),
    );
  }
}
```

### Advanced Configuration

```dart
CustomDraggableList<String>(
  items: items,
  itemBuilder: (item, index) => ListTile(title: Text(item)),
  onReorder: (oldIndex, newIndex) {
    // Handle reordering
  },
  scrollController: _scrollController,
  config: const ReorderableListConfig(
    // Visual customization
    insertIndicatorColor: Colors.blue,
    insertIndicatorHeight: 4.0,
    
    // Feedback customization
    feedbackScale: 0.8,
    feedbackOpacity: 0.9,
    feedbackMaxWidth: 300.0,
    feedbackMaxHeight: 200.0,
    
    // Selected item customization
    selectedWidgetScale: 0.95,
    selectedWidgetOpacity: 0.7,
    
    // Auto-scroll configuration
    autoScrollZone: 100.0,
    maxScrollSpeed: 20.0,
    
    // Padding configuration
    topPadding: 0.0,
    bottomPadding: 80.0,
    
    // Animation configuration
    animationDuration: Duration(milliseconds: 200),
    autoScrollDuration: Duration(milliseconds: 16),
  ),
  feedbackBuilder: (item, index) {
    // Custom feedback widget
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(item),
    );
  },
)
```

## API Reference

### CustomDraggableList<T>

The main widget that provides reorderable list functionality.

#### Properties

- `items` (List<T>) - The list of items to display
- `itemBuilder` (Widget Function(T item, int index)) - Builder for list items
- `onReorder` (void Function(int oldIndex, int newIndex)) - Callback when items are reordered
- `scrollController` (ScrollController?) - Optional scroll controller
- `config` (ReorderableListConfig) - Configuration object
- `feedbackBuilder` (Widget Function(T item, int index)?) - Optional custom feedback widget

### ReorderableListConfig

Configuration class for customizing the reorderable list behavior.

#### Properties

- `insertIndicatorColor` (Color) - Color of the insertion indicator
- `insertIndicatorHeight` (double) - Height of the insertion indicator
- `feedbackScale` (double) - Scale factor for the feedback widget
- `feedbackOpacity` (double) - Opacity of the feedback widget
- `feedbackMaxWidth` (double) - Maximum width of the feedback widget
- `feedbackMaxHeight` (double) - Maximum height of the feedback widget
- `selectedWidgetScale` (double) - Scale factor for the selected widget
- `selectedWidgetOpacity` (double) - Opacity of the selected widget
- `autoScrollZone` (double) - Zone height for auto-scrolling
- `maxScrollSpeed` (double) - Maximum auto-scroll speed
- `topPadding` (double) - Top padding of the list
- `bottomPadding` (double) - Bottom padding of the list
- `animationDuration` (Duration) - Duration for animations
- `autoScrollDuration` (Duration) - Duration for auto-scroll updates

## Examples

### Simple List

```dart
CustomDraggableList<String>(
  items: ['A', 'B', 'C'],
  itemBuilder: (item, index) => ListTile(title: Text(item)),
  onReorder: (oldIndex, newIndex) {
    // Handle reordering
  },
)
```

### Custom Styled List

```dart
CustomDraggableList<MyItem>(
  items: myItems,
  itemBuilder: (item, index) => Card(
    child: ListTile(
      title: Text(item.title),
      subtitle: Text(item.description),
      leading: CircleAvatar(child: Text(item.id.toString())),
    ),
  ),
  onReorder: (oldIndex, newIndex) {
    // Handle reordering
  },
  config: ReorderableListConfig(
    insertIndicatorColor: Colors.orange,
    feedbackScale: 0.9,
  ),
)
```

### With Custom Feedback

```dart
CustomDraggableList<Item>(
  items: items,
  itemBuilder: (item, index) => ItemWidget(item),
  onReorder: (oldIndex, newIndex) {
    // Handle reordering
  },
  feedbackBuilder: (item, index) => Transform.rotate(
    angle: 0.1,
    child: ItemWidget(item),
  ),
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/AbdY-G/ReorderableV2.0/issues).