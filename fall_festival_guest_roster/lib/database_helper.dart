import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'fall_festival_guest_roster.db';
  static const _databaseVersion = 1;

  static const folderTable = 'folders';
  static const cardTable = 'cards';

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < _databaseVersion) {
      await _createTables(db);
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        suit TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        image_ref TEXT,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id)
          REFERENCES folders(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_cards_folder_id
      ON cards(folder_id)
    ''');
  }

  Future<int> insertFolder(Map<String, dynamic> row) async {
    return _db.insert(folderTable, row);
  }

  Future<List<Map<String, dynamic>>> getFoldersWithCounts() async {
    return _db.rawQuery('''
      SELECT
        f.id,
        f.name,
        f.created_at,
        COUNT(c.id) AS card_count
      FROM folders f
      LEFT JOIN cards c ON c.folder_id = f.id
      GROUP BY f.id, f.name, f.created_at
      ORDER BY f.created_at DESC
    ''');
  }

  Future<int> updateFolder(Map<String, dynamic> row) async {
    final id = row['id'] as int;
    return _db.update(
      folderTable,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFolder(int id) async {
    return _db.delete(
      folderTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertCard(Map<String, dynamic> row) async {
    return _db.insert(cardTable, row);
  }

  Future<List<Map<String, dynamic>>> getCards(int folderId) async {
    return _db.query(
      cardTable,
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'id ASC',
    );
  }

  Future<int> updateCard(Map<String, dynamic> row) async {
    final id = row['id'] as int;
    return _db.update(
      cardTable,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCard(int id) async {
    return _db.delete(
      cardTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}