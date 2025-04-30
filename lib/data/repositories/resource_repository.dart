import 'package:imperio_tribal_app/core/database/database_helper.dart';
import 'package:imperio_tribal_app/data/models/resource_model.dart';

class ResourceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(ResourceModel resource) async {
    final db = await _dbHelper.database;
    return await db.insert('resources', resource.toMap());
  }

  Future<ResourceModel?> findById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('resources', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return ResourceModel.fromMap(maps.first);
  }

  Future<ResourceModel?> findByVillageId(int villageId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'resources',
      where: 'village_id = ?',
      whereArgs: [villageId],
    );

    if (maps.isEmpty) return null;
    return ResourceModel.fromMap(maps.first);
  }

  Future<List<ResourceModel>> findAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('resources');
    return maps.map((map) => ResourceModel.fromMap(map)).toList();
  }

  Future<int> update(ResourceModel resource) async {
    final db = await _dbHelper.database;
    return await db.update(
      'resources',
      resource.toMap(),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  Future<int> updateResources(
    int villageId, {
    int? wood,
    int? clay,
    int? iron,
  }) async {
    final resource = await findByVillageId(villageId);
    if (resource == null) return 0;

    final updatedResource = resource.copyWith(
      wood: wood ?? resource.wood,
      clay: clay ?? resource.clay,
      iron: iron ?? resource.iron,
      lastUpdatedAt: DateTime.now(),
    );

    return await update(updatedResource);
  }

  Future<int> updateProduction(
    int villageId, {
    int? woodProduction,
    int? clayProduction,
    int? ironProduction,
  }) async {
    final resource = await findByVillageId(villageId);
    if (resource == null) return 0;

    final updatedResource = resource.copyWith(
      woodProduction: woodProduction ?? resource.woodProduction,
      clayProduction: clayProduction ?? resource.clayProduction,
      ironProduction: ironProduction ?? resource.ironProduction,
      lastUpdatedAt: DateTime.now(),
    );

    return await update(updatedResource);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('resources', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteByVillageId(int villageId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'resources',
      where: 'village_id = ?',
      whereArgs: [villageId],
    );
  }
}
