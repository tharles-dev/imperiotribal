import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:imperio_tribal_app/core/database/migrations/initial_migration.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('imperio_tribal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: InitialMigration.version,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await InitialMigration.createTables(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Implementar lógica de upgrade quando necessário
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
