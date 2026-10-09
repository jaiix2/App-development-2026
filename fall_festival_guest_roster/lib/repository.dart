import 'database_helper.dart';
import 'folder.dart';
import 'card_model.dart';

class Repository {
  final DatabaseHelper dbHelper;

  Repository(this.dbHelper);

  // Folder methods

  Future<int> insertFolder(Folder folder) async {
    return await dbHelper.insertFolder(folder.toMap());
  }

  Future<List<Folder>> getFolders() async {
    final rows = await dbHelper.getFoldersWithCounts();

    return rows.map((row) => Folder.fromMap(row)).toList();
  }

  Future<int> updateFolder(Folder folder) async {
    return await dbHelper.updateFolder(folder.toMap());
  }

  Future<int> deleteFolder(int id) async {
    return await dbHelper.deleteFolder(id);
  }

  // Card methods

  Future<int> insertCard(CardModel card) async {
    return await dbHelper.insertCard(card.toMap());
  }

  Future<List<CardModel>> getCards(int folderId) async {
    final rows = await dbHelper.getCards(folderId);

    return rows.map((row) => CardModel.fromMap(row)).toList();
  }

  Future<int> updateCard(CardModel card) async {
    return await dbHelper.updateCard(card.toMap());
  }

  Future<int> deleteCard(int id) async {
    return await dbHelper.deleteCard(id);
  }
}