import 'package:flutter/material.dart';
import 'package:reorderable_2_0/widgets/custom_reorderable_list.dart';

void main() =>
    runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> items = [];

  int _getWidgetType(int index) {
    // Создаем несколько очень больших виджетов
    switch (index) {
      case 2:
      case 7:
      case 12:
      case 17:
        return 5; // Очень большой виджет (больше экрана)
      case 1:
      case 6:
      case 11:
      case 16:
        return 6; // Супер большой виджет (намного больше экрана)
      default:
        return index % 5; // Обычные типы виджетов
    }
  }
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    items = List.generate(20, (index) => {
      'text': 'Item ${index + 1}',
      'type': _getWidgetType(index), // Специальная функция для типов виджетов
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorderable List v 2.0'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: CustomDraggableList(
            scrollController: _scrollController,
            children: items.asMap().entries.map((entry) => 
              _buildListItem(entry.value, entry.key)
            ).toList(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = items.removeAt(oldIndex);
                items.insert(newIndex, item);
              });
            },
            feedbackBuilder: (child, index) => Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  items[index]['text'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item, int index) {
    // Разные размеры для разных элементов
    Widget content;
    String itemText = item['text'];
    int widgetType = item['type'];
    
    switch (widgetType) {
      case 0: // Маленький элемент
        content = _buildSmallItem(itemText, index);
        break;
      case 1: // Средний элемент
        content = _buildMediumItem(itemText, index);
        break;
      case 2: // Большой элемент
        content = _buildLargeItem(itemText, index);
        break;
      case 3: // Очень большой элемент
        content = _buildExtraLargeItem(itemText, index);
        break;
      case 4: // Карточка
        content = _buildCardItem(itemText, index);
        break;
      case 5: // Очень большой виджет (больше экрана)
        content = _buildVeryLargeItem(itemText, index);
        break;
      case 6: // Супер большой виджет (намного больше экрана)
        content = _buildSuperLargeItem(itemText, index);
        break;
      default: // Карточка
        content = _buildCardItem(itemText, index);
        break;
    }
    
    return Container(
      key: ValueKey(itemText),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: content,
    );
  }

  Widget _buildSmallItem(String item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.drag_handle, color: Colors.grey, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMediumItem(String item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Medium sized item with subtitle',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.drag_handle, color: Colors.grey),
      ),
    );
  }

  Widget _buildLargeItem(String item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.drag_handle, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Large item with detailed description and multiple lines of text to show how the reorderable list handles different content sizes.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange[600], size: 16),
                Icon(Icons.favorite, color: Colors.red[400], size: 16),
                Icon(Icons.bookmark, color: Colors.blue[600], size: 16),
                const Spacer(),
                Text(
                  'Large Item',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraLargeItem(String item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  radius: 20,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.drag_handle, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Extra large item with comprehensive content including multiple sections, icons, and detailed information to test the reorderable list with complex layouts.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Category A',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Priority High',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 18),
                Icon(Icons.favorite, color: Colors.red[400], size: 18),
                Icon(Icons.bookmark, color: Colors.blue[600], size: 18),
                Icon(Icons.share, color: Colors.green[600], size: 18),
                const Spacer(),
                Text(
                  'Extra Large Item',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(String item, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.cyan[100]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.cyan,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.drag_handle, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Card style item with gradient background and modern design.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber[600], size: 16),
                  const SizedBox(width: 8),
                  Icon(Icons.favorite, color: Colors.red[400], size: 16),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.cyan[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Card',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVeryLargeItem(String item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red[300]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 25,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.drag_handle, color: Colors.grey, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'VERY LARGE ITEM - This is an extremely large widget that is designed to be bigger than most phone screens. It contains multiple sections with detailed information, images, and interactive elements.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 40, color: Colors.red[600]),
                    const SizedBox(height: 8),
                    Text(
                      'Image Placeholder',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Large Category',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Priority Critical',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.yellow[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Size: XXL',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 20),
                const SizedBox(width: 12),
                Icon(Icons.favorite, color: Colors.red[400], size: 20),
                const SizedBox(width: 12),
                Icon(Icons.bookmark, color: Colors.blue[600], size: 20),
                const SizedBox(width: 12),
                Icon(Icons.share, color: Colors.green[600], size: 20),
                const SizedBox(width: 12),
                Icon(Icons.download, color: Colors.purple[600], size: 20),
                const Spacer(),
                Text(
                  'VERY LARGE ITEM',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Additional content section with more detailed information about this very large item. This section is designed to make the widget even taller and test the scrolling behavior of the reorderable list.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuperLargeItem(String item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple[100],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.deepPurple[300]!, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  radius: 30,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.drag_handle, color: Colors.grey, size: 32),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'SUPER LARGE ITEM - This is an enormous widget that is designed to be significantly larger than any phone screen. It contains extensive content including multiple sections, detailed descriptions, interactive elements, and visual components.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.deepPurple[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, size: 50, color: Colors.deepPurple[600]),
                    const SizedBox(height: 12),
                    Text(
                      'Large Image Gallery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.purple[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 30, color: Colors.purple[600]),
                          const SizedBox(height: 8),
                          Text(
                            'Chart Data',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.purple[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.indigo[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics, size: 30, color: Colors.indigo[600]),
                          const SizedBox(height: 8),
                          Text(
                            'Analytics',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.indigo[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Super Large Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Priority Ultra High',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.indigo[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Size: XXXL',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Premium Feature',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 24),
                const SizedBox(width: 16),
                Icon(Icons.favorite, color: Colors.red[400], size: 24),
                const SizedBox(width: 16),
                Icon(Icons.bookmark, color: Colors.blue[600], size: 24),
                const SizedBox(width: 16),
                Icon(Icons.share, color: Colors.green[600], size: 24),
                const SizedBox(width: 16),
                Icon(Icons.download, color: Colors.purple[600], size: 24),
                const SizedBox(width: 16),
                Icon(Icons.settings, color: Colors.orange[600], size: 24),
                const Spacer(),
                Text(
                  'SUPER LARGE ITEM',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Extended content section with comprehensive information about this super large item. This section contains detailed descriptions, specifications, and additional data that makes this widget extremely tall and perfect for testing the auto-scroll functionality and the ability of the reorderable list to handle oversized content.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple[200]!),
              ),
              child: Center(
                child: Text(
                  'This widget is intentionally very tall to test scrolling and drag-and-drop with oversized content',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
