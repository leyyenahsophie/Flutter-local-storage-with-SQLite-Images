import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static const _databaseName = "CardOrganizer.db";
  static const _databaseVersion = 1;

  // Table names
  static const folderTable = 'folders';
  static const cardTable = 'cards';

  // Column names
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnSuit = 'suit';
  static const columnFolderId = 'folder_id';
  static const columnImageUrl = 'image_url';
  static const columnTimestamp = 'timestamp';

  late Database _db;

  // Initialize the database
  Future<void> init() async {
    try {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );   
  }catch(e){
    print("Database intialization failed: $e");
  }
}

  // Method to create database schema
  Future _onCreate(Database db, int version) async {
    // Create Folders Table
    await db.execute('''
      CREATE TABLE $folderTable (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnTimestamp TEXT NOT NULL
      )
    ''');

    // Create Cards Table
    await db.execute('''
      CREATE TABLE $cardTable (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnSuit TEXT NOT NULL,
        $columnFolderId INTEGER,
        $columnImageUrl TEXT NOT NULL,
        FOREIGN KEY ($columnFolderId) REFERENCES $folderTable($columnId)
      )
    ''');

    // Prepopulate Folders with default suits
    List<Map<String, dynamic>> folders = [
      {'name': 'Hearts'},
      {'name': 'Spades'},
      {'name': 'Diamonds'},
      {'name': 'Clubs'},
    ];

    // Insert predefined folders into the database
    for (var folder in folders) {
      await db.insert(folderTable, {
        columnName: folder['name'],
        columnTimestamp: DateTime.now().toString()
      });
    }

    // Prepopulate Cards Table with a standard deck (1-13 for each suit)
    List<String> suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    List<String> ranks = [
      'Ace',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'Jack',
      'Queen',
      'King'
    ];
    int folderId = 1;

    // Insert each card into the database with an associated image URL
    for (String suit in suits) {
      for (String rank in ranks) {
        await db.insert(cardTable, {
          columnName: '$rank of $suit',
          columnSuit: suit,
          columnFolderId: folderId,
          columnImageUrl:
              'assets/images/${rank.toLowerCase()}_of_${suit.toLowerCase()}.png'
        });
      }
      folderId++;
    }
  }

 // Query all folders
  Future<List<Map<String, dynamic>>> queryAllFolders() async {
    return await _db.query(folderTable);
  }

Future<List<Map<String, dynamic>>> queryCardsByFolder(int folderId) async {
  return await _db.query(
    cardTable,
    where: '$columnFolderId = ?',
    whereArgs: [folderId],
  );
}

}
