class CardModel {
  final int? id;
  final String title;
  final String suit;
  final String notes;
  final String? imageRef;
  final int folderId;

  CardModel({
    this.id,
    required this.title,
    required this.suit,
    this.notes = '',
    this.imageRef,
    required this.folderId,
  });

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      title: map['title'],
      suit: map['suit'],
      notes: map['notes'] ?? '',
      imageRef: map['image_ref'],
      folderId: map['folder_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'suit': suit,
      'notes': notes,
      'image_ref': imageRef,
      'folder_id': folderId,
    };
  }
}
