import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final String? color;
  final List<String> tags;

  const NoteModel({
    this.id = '',
    required this.title,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.color,
    this.tags = const [],
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? color,
    List<String>? tags,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
      tags: tags ?? this.tags,
    );
  }

  // Convert to JSON for Firestore (used by HabitModel)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPinned': isPinned,
      'color': color,
      'tags': tags,
    };
  }

  // Legacy method for compatibility
  Map<String, dynamic> toMap() => toJson();

  // Main factory constructor used by HabitModel
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      isPinned: json['isPinned'] ?? false,
      color: json['color'],
      tags: _parseStringList(json['tags']),
    );
  }

  // Factory constructor for direct Firestore documents
  factory NoteModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return NoteModel(
      id: docId,
      title: data['title'] ?? '',
      text: data['text'] ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      isPinned: data['isPinned'] ?? false,
      color: data['color'],
      tags: _parseStringList(data['tags']),
    );
  }

  // Legacy method for compatibility
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel.fromJson(map);
  }

  // Helper method to parse datetime values that could be in different formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  // Helper method to parse string lists safely
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }
}
