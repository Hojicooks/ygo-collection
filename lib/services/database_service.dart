// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/card_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ygo_collection.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE inventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ygo_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            set_code TEXT NOT NULL,
            set_name TEXT NOT NULL,
            rarity TEXT NOT NULL,
            rarity_code TEXT NOT NULL,
            price REAL NOT NULL,
            image_url TEXT,
            added_at TEXT NOT NULL,
            note TEXT
          )
        ''');
      },
    );
  }

  Future<int> addCard(InventoryCard card) async {
    final db = await database;
    return await db.insert('inventory', card.toMap());
  }

  Future<List<InventoryCard>> getAllCards() async {
    final db = await database;
    final maps = await db.query('inventory', orderBy: 'added_at DESC');
    return maps.map((m) => InventoryCard.fromMap(m)).toList();
  }

  Future<int> deleteCard(int id) async {
    final db = await database;
    return await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    final cards = await getAllCards();
    final total = cards.fold<double>(0, (sum, c) => sum + c.price);
    final countByRarity = <String, int>{};
    for (final c in cards) {
      countByRarity[c.rarity] = (countByRarity[c.rarity] ?? 0) + 1;
    }
    final mostExpensive = cards.isEmpty
        ? null
        : cards.reduce((a, b) => a.price > b.price ? a : b);

    return {
      'count': cards.length,
      'total': total,
      'byRarity': countByRarity,
      'mostExpensive': mostExpensive,
    };
  }
}
