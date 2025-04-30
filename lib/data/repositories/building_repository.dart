import 'package:sqflite/sqflite.dart';
import 'package:imperio_tribal_app/core/database/database_helper.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/data/models/building_model.dart';

class BuildingRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> create(BuildingModel building) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert(
        'buildings',
        building.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.info('Edifício criado com sucesso: ${building.type}');
      return id;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar edifício', e, stackTrace);
      rethrow;
    }
  }

  Future<BuildingModel?> findById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'buildings',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return BuildingModel.fromMap(maps.first);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar edifício por ID', e, stackTrace);
      rethrow;
    }
  }

  Future<List<BuildingModel>> findByVillageId(int villageId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'buildings',
        where: 'village_id = ?',
        whereArgs: [villageId],
      );

      return maps.map((map) => BuildingModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar edifícios da aldeia', e, stackTrace);
      rethrow;
    }
  }

  Future<List<BuildingModel>> findAll() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('buildings');
      return maps.map((map) => BuildingModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar todos os edifícios', e, stackTrace);
      rethrow;
    }
  }

  Future<void> update(BuildingModel building) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'buildings',
        building.toMap(),
        where: 'id = ?',
        whereArgs: [building.id],
      );
      AppLogger.info('Edifício atualizado com sucesso: ${building.type}');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar edifício', e, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('buildings', where: 'id = ?', whereArgs: [id]);
      AppLogger.info('Edifício deletado com sucesso: $id');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao deletar edifício', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteByVillageId(int villageId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'buildings',
        where: 'village_id = ?',
        whereArgs: [villageId],
      );
      AppLogger.info('Edifícios da aldeia deletados com sucesso: $villageId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao deletar edifícios da aldeia', e, stackTrace);
      rethrow;
    }
  }

  Future<void> createInitialBuildings(int villageId, int createdAt) async {
    try {
      for (final type in BuildingModel.initialBuildings) {
        final building = BuildingModel.createInitialBuilding(
          villageId: villageId,
          type: type,
          createdAt: createdAt,
        );
        await create(building);
      }
      AppLogger.info(
        'Edifícios iniciais criados com sucesso para a aldeia: $villageId',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar edifícios iniciais', e, stackTrace);
      rethrow;
    }
  }
}
