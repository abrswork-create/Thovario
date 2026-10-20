/// Immutable data model representing a private journal entry in Thovario.
class Thought {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  const Thought({
    required this.id,
    this.title = '',
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  /// Creates a copy of this [Thought] with updated values.
  Thought copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return Thought(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Converts this [Thought] to a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// Constructs a [Thought] from a database map.
  factory Thought.fromMap(Map<String, dynamic> map) {
    return Thought(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Thought &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, content, createdAt, updatedAt, isFavorite);
  }

  @override
  String toString() {
    // Avoid logging sensitive content in logs
    return 'Thought(id: $id, title: $title, isFavorite: $isFavorite, createdAt: $createdAt)';
  }
}
