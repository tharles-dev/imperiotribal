import 'package:imperio_tribal_app/core/database/database_helper.dart';
import 'package:imperio_tribal_app/data/models/user_model.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(UserModel user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> findById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> findByName(String name) async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', where: 'name = ?', whereArgs: [name]);

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<List<UserModel>> findAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<List<UserModel>> findNpcs() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', where: 'is_npc = ?', whereArgs: [1]);
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<int> update(UserModel user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> exists() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users');
    return maps.isNotEmpty;
  }
}
