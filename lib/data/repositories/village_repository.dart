import 'package:imperio_tribal_app/core/database/database_helper.dart';
import 'package:imperio_tribal_app/data/models/village_model.dart';

class VillageRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(VillageModel village) async {
    final db = await _dbHelper.database;
    return await db.insert('villages', village.toMap());
  }

  Future<VillageModel?> findById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('villages', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return VillageModel.fromMap(maps.first);
  }

  Future<List<VillageModel>> findByUserId(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'villages',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => VillageModel.fromMap(map)).toList();
  }

  Future<List<VillageModel>> findAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('villages');
    return maps.map((map) => VillageModel.fromMap(map)).toList();
  }

  Future<VillageModel?> findByPosition(int x, int y) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'villages',
      where: 'x = ? AND y = ?',
      whereArgs: [x, y],
    );

    if (maps.isEmpty) return null;
    return VillageModel.fromMap(maps.first);
  }

  Future<bool> isPositionOccupied(int x, int y) async {
    final village = await findByPosition(x, y);
    return village != null;
  }

  Future<int> update(VillageModel village) async {
    final db = await _dbHelper.database;
    return await db.update(
      'villages',
      village.toMap(),
      where: 'id = ?',
      whereArgs: [village.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('villages', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteByUserId(int userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'villages',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
