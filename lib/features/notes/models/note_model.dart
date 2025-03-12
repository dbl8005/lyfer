class NoteModel {
  final String id; // Add an ID field for the note
  final String title;
  final String text;
  final DateTime createdAt;

  const NoteModel({
    this.id = '', // Default ID to an empty string
    required this.title,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.color,
    this.tags = const [],
  });

  // Add a factory constructor for Firestore documents
  factory NoteModel.fromFirestore(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isPinned: map['isPinned'] ?? false,
      color: map['color'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
  final DateTime updatedAt;
  final bool isPinned;
  final String? color;
  final List<String> tags;

  NoteModel copyWith({
    String? title,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? color,
    List<String>? tags,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isPinned': isPinned,
      'color': color,
      'tags': tags,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isPinned: map['isPinned'] ?? false,
      color: map['color'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
