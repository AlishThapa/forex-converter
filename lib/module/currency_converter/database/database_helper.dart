import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/rate_models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  final dbName = 'forex.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rates(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        disclaimer TEXT,
        license TEXT,
        timestamp INTEGER,
        base TEXT,
        rate TEXT
      )
    ''');
    await db.execute('''
    CREATE TABLE currencies(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      currencyData TEXT
    )
  ''');
  }

  Future<int> insertRatesToLocalDb(RatesModel rates) async {
    final db = await database;
    return await db.insert(
        'rates',
        {
          'disclaimer': rates.disclaimer,
          'license': rates.license,
          'timestamp': rates.timestamp,
          'base': rates.base,
          'rate': json.encode(rates.rates),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<RatesModel?> getLatestRatesFromLocalDb() async {
    final db = await database;
    final maps = await db.query('rates');
    if (maps.isNotEmpty) {
      final rates = Map<String, dynamic>.from(maps.first);
      rates['rates'] = json.decode(rates['rate']);
      return RatesModel.fromJson(rates);
    }
    return null;
  }


  Future<int> insertCurrenciesToLocalDb(Map<String, String> currencies) async {
    final db = await database;
    return await db.insert(
      'currencies',
      {'currencyData': json.encode(currencies)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>?> getCurrenciesFromLocalDb() async {
    final db = await database;
    final maps = await db.query('currencies');
    if (maps.isNotEmpty) {
      final currencyData = Map<String, dynamic>.from(maps.first);
      return Map<String, String>.from(json.decode(currencyData['currencyData']));
    }
    return null;
  }

}
