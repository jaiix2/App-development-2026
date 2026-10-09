class Folder {
  final int? id;
  final String name;
  final String createdAt;
  final int cardCount;

  Folder({
    this.id,
    required this.name,
    required this.createdAt,
    this.cardCount = 0,
  });

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      createdAt: map['created_at'],
      cardCount: map['card_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
    };
  }
}