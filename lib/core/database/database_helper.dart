import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:imperio_tribal_app/core/database/migrations/initial_migration.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';

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
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      AppLogger.info('Inicializando banco de dados em: $path');

      final db = await openDatabase(
        path,
        version: InitialMigration.version,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );

      AppLogger.info('Banco de dados criado com sucesso');
      return db;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao inicializar banco de dados', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      AppLogger.info('Criando tabelas do banco de dados...');
      await InitialMigration.createTables(db);
      AppLogger.info('Tabelas criadas com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar tabelas', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Implementar lógica de upgrade quando necessário
    AppLogger.info(
      'Atualizando banco de dados da versão $oldVersion para $newVersion',
    );
  }

  Future<void> close() async {
    try {
      final db = await instance.database;
      await db.close();
      AppLogger.info('Banco de dados fechado com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao fechar banco de dados', e, stackTrace);
      rethrow;
    }
  }
}
