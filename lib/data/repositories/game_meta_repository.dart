import 'package:imperio_tribal_app/core/database/database_helper.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/data/models/game_meta_model.dart';

class GameMetaRepository {
  final _db = DatabaseHelper.instance;

  // Cria um novo registro de meta
  Future<int> create(GameMetaModel meta) async {
    try {
      final db = await _db.database;
      final id = await db.insert('game_meta', meta.toMap());
      AppLogger.info('Meta criada com sucesso: $id');
      return id;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar meta', e, stackTrace);
      rethrow;
    }
  }

  // Busca o registro de meta
  Future<GameMetaModel?> find() async {
    try {
      final db = await _db.database;
      final maps = await db.query('game_meta', limit: 1);

      if (maps.isEmpty) return null;

      final meta = GameMetaModel.fromMap(maps.first);
      AppLogger.info('Meta encontrada: ${meta.lastOpenedAt}');
      return meta;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar meta', e, stackTrace);
      rethrow;
    }
  }

  // Atualiza o registro de meta
  Future<void> update(GameMetaModel meta) async {
    try {
      final db = await _db.database;
      await db.update(
        'game_meta',
        meta.toMap(),
        where: 'id = ?',
        whereArgs: [meta.id],
      );
      AppLogger.info('Meta atualizada com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar meta', e, stackTrace);
      rethrow;
    }
  }

  // Atualiza apenas o last_opened_at
  Future<void> updateLastOpenedAt(DateTime lastOpenedAt) async {
    try {
      final db = await _db.database;
      await db.update(
        'game_meta',
        {'last_opened_at': lastOpenedAt.millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [1], // Assumindo que sempre teremos apenas um registro
      );
      AppLogger.info('Last opened at atualizado: $lastOpenedAt');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar last opened at', e, stackTrace);
      rethrow;
    }
  }
}
