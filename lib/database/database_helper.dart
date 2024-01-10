// database_helper.dart

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = 'NewsDatabase.db';
  static final _databaseVersion = 4;

  static final favoriteTable = 'favorite_articles';
  static final columnId = '_id';
  static final columnTitle = 'title';
  static final columnDescription = 'description';
  static final columnImageUrl = 'image';

  static final userTable = 'users';
  static final columnUserId = '_userId';
  static final columnUserUsername = 'username';
  static final columnUserPassword = 'password';

  static final newsTable = 'news_articles'; // New table for news articles
  static final columnNewsId = '_newsId';
  static final columnNewsTitle = 'title';
  static final columnNewsDescription = 'description';
  static final columnNewsImage = 'image';
  static final columnNewsViews = 'views';
  static final columnNewsCategory = 'category';
  static final columnNewsPublishedDate = 'published_date';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // This opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $favoriteTable (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT,
        $columnDescription TEXT,
        $columnImageUrl TEXT
      )
    ''');

    await createUserTable(db);
    await createNewsTable(db); // Create the news table
  }

  // Handle database schema changes or migrations
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {

  }

  // Helper methods

  // Insert a row into the database
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(favoriteTable, row);
  }

  // Delete a row from the database
  Future<int> delete(String title) async {
    Database db = await instance.database;
    return await db.delete(favoriteTable, where: '$columnTitle = ?', whereArgs: [title]);
  }

  // Query all rows in the database
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(favoriteTable);
  }

  Future<List<Map<String, dynamic>>> GetAllNews() async {
    Database db = await instance.database;
    return await db.query(newsTable);
  }

  Future<void> createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE $userTable (
        $columnUserId INTEGER PRIMARY KEY,
        $columnUserUsername TEXT,
        $columnUserPassword TEXT
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(userTable, row);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(userTable,
        where: '$columnUserUsername = ?', whereArgs: [username]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<void> createNewsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $newsTable (
        $columnNewsId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNewsTitle TEXT,
        $columnNewsDescription TEXT,
        $columnNewsImage TEXT,
        $columnNewsViews INTEGER,
        $columnNewsCategory TEXT,
        $columnNewsPublishedDate TEXT
      )
    ''');
  }

  Future<int> insertNews(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(newsTable, row);
  }

  Future<void> updateViews(String title, int views) async {
    Database db = await instance.database;
    await db.update(newsTable, {'views': views}, where: '$columnNewsTitle = ?', whereArgs: [title]);
  }

  Future<List<Map<String, dynamic>>> getNewsByCategory(String category) async {
    Database db = await instance.database;
    return await db.query(newsTable, where: '$columnNewsCategory = ?', whereArgs: [category]);
  }

  Future<List<Map<String, dynamic>>> getPopularNews(String sorting) async {
    final Database db = await instance.database;
    late List<Map<String, dynamic>> articles;

    switch (sorting) {
      case 'most_views':
        articles = await db.rawQuery('SELECT * FROM news_articles ORDER BY views DESC');
        break;
      case 'least_views':
        articles = await db.rawQuery('SELECT * FROM news_articles ORDER BY views ASC');
        break;
      default:
        articles = await db.rawQuery('SELECT * FROM news_articles');
        break;
    }

    return articles;
  }

}
