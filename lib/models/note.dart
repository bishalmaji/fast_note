import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Note extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  DateTime createdAt;
  
  @HiveField(4)
  DateTime updatedAt;
  
  @HiveField(5)
  String? colorHex;
  
  @HiveField(6)
  bool isPinned;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.colorHex,
    this.isPinned = false,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  String get displayTitle {
    if (title.trim().isNotEmpty) return title;
    final firstLine = content.split('\n').firstWhere(
      (line) => line.trim().isNotEmpty, 
      orElse: () => ''
    );
    return firstLine.isNotEmpty ? firstLine : 'Untitled Note';
  }

  String get previewContent {
    final contentWithoutTitle = title.isEmpty ? 
      content.split('\n').skip(1).join('\n') : content;
    return contentWithoutTitle.length > 100 
      ? '${contentWithoutTitle.substring(0, 100)}...' 
      : contentWithoutTitle;
  }

  void updateNote({String? title, String? content}) {
    this.title = title ?? this.title;
    this.content = content ?? this.content;
    updatedAt = DateTime.now();
  }


  bool get hasLinks {
    final urlRegex = RegExp(
      r'https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)',
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegex.hasMatch(content);
  }

  List<String> get extractedLinks {
    final urlRegex = RegExp(
      r'https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)',
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegex.allMatches(content).map((match) => match.group(0)!).toList();
  }
}