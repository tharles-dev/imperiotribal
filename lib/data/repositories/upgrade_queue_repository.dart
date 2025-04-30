import 'package:imperio_tribal_app/core/database/database_helper.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/data/models/upgrade_queue_model.dart';

class UpgradeQueueRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(UpgradeQueueModel upgrade) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('upgrades_queue', upgrade.toMap());
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar upgrade na fila', e, stackTrace);
      rethrow;
    }
  }

  Future<List<UpgradeQueueModel>> findAllPending() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'upgrades_queue',
        where: 'status = ?',
        whereArgs: ['pending'],
      );
      return maps.map((map) => UpgradeQueueModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar upgrades pendentes', e, stackTrace);
      rethrow;
    }
  }

  Future<UpgradeQueueModel?> findById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'upgrades_queue',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return UpgradeQueueModel.fromMap(maps.first);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar upgrade por ID', e, stackTrace);
      rethrow;
    }
  }

  Future<UpgradeQueueModel?> findActiveByBuildingId(int buildingId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'upgrades_queue',
        where: 'building_id = ? AND status = ?',
        whereArgs: [buildingId, 'pending'],
      );

      if (maps.isEmpty) return null;
      return UpgradeQueueModel.fromMap(maps.first);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao buscar upgrade ativo por building ID',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> hasActiveUpgrade(int buildingId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'upgrades_queue',
        where: 'building_id = ? AND status = ?',
        whereArgs: [buildingId, 'pending'],
      );
      return result.isNotEmpty;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao verificar upgrade ativo por building ID',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'upgrades_queue',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar status do upgrade', e, stackTrace);
      rethrow;
    }
  }

  Future<List<UpgradeQueueModel>> findByVillageId(int villageId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'upgrades_queue',
        where: 'village_id = ? AND status = ?',
        whereArgs: [villageId, 'pending'],
      );
      AppLogger.info(
        'Encontrados ${maps.length} upgrades pendentes para a vila $villageId',
      );
      return maps.map((map) => UpgradeQueueModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar upgrades da aldeia', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteCompleted() async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'upgrades_queue',
        where: 'status = ?',
        whereArgs: ['completed'],
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao deletar upgrades completados', e, stackTrace);
      rethrow;
    }
  }
}
