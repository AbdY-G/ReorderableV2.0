enum BlockType {
  text,
  image,
  audio,
}

class Log {
  final String id;
  final String content;
  final BlockType blockType;
  final DateTime timestamp;
  final String? title;
  final String? caption;
  final Duration? duration;

  const Log({
    required this.id,
    required this.content,
    required this.blockType,
    required this.timestamp,
    this.title,
    this.caption,
    this.duration,
  });

  // Создание TextBlock лога
  factory Log.text({
    required String id,
    required String content,
    String? title,
    DateTime? timestamp,
  }) {
    return Log(
      id: id,
      content: content,
      blockType: BlockType.text,
      title: title,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  // Создание ImageBlock лога
  factory Log.image({
    required String id,
    required String imageUrl,
    String? caption,
    DateTime? timestamp,
  }) {
    return Log(
      id: id,
      content: imageUrl,
      blockType: BlockType.image,
      caption: caption,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  // Создание AudioBlock лога
  factory Log.audio({
    required String id,
    required String audioUrl,
    String? title,
    Duration? duration,
    DateTime? timestamp,
  }) {
    return Log(
      id: id,
      content: audioUrl,
      blockType: BlockType.audio,
      title: title,
      duration: duration,
      timestamp: timestamp ?? DateTime.now(),
    );
  }
}
