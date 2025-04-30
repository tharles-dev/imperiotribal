import 'package:sqflite/sqflite.dart';
import 'package:imperio_tribal_app/core/utils/logger.dart';

class InitialMigration {
  static const version = 1;

  static Future<void> createTables(Database db) async {
    try {
      AppLogger.info('Criando tabela users...');
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          tribe TEXT NOT NULL,
          is_npc BOOLEAN NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL
        )
      ''');

      AppLogger.info('Criando tabela villages...');
      await db.execute('''
        CREATE TABLE villages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          x INTEGER NOT NULL,
          y INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      AppLogger.info('Criando tabela resources...');
      await db.execute('''
        CREATE TABLE resources (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          village_id INTEGER NOT NULL,
          wood INTEGER NOT NULL DEFAULT 0,
          clay INTEGER NOT NULL DEFAULT 0,
          iron INTEGER NOT NULL DEFAULT 0,
          wood_production INTEGER NOT NULL DEFAULT 0,
          clay_production INTEGER NOT NULL DEFAULT 0,
          iron_production INTEGER NOT NULL DEFAULT 0,
          last_updated_at INTEGER NOT NULL,
          FOREIGN KEY (village_id) REFERENCES villages (id)
        )
      ''');

      AppLogger.info('Criando tabela buildings...');
      await db.execute('''
        CREATE TABLE buildings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          village_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          level INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (village_id) REFERENCES villages (id)
        )
      ''');

      AppLogger.info('Criando tabela upgrades_queue...');
      await db.execute('''
        CREATE TABLE upgrades_queue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          building_id INTEGER NOT NULL,
          village_id INTEGER NOT NULL,
          target_level INTEGER NOT NULL,
          start_time INTEGER NOT NULL,
          end_time INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          FOREIGN KEY (building_id) REFERENCES buildings (id),
          FOREIGN KEY (village_id) REFERENCES villages (id)
        )
      ''');

      AppLogger.info('Criando tabela troops...');
      await db.execute('''
        CREATE TABLE troops (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          village_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (village_id) REFERENCES villages (id)
        )
      ''');

      AppLogger.info('Criando tabela training_queue...');
      await db.execute('''
        CREATE TABLE training_queue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          village_id INTEGER NOT NULL,
          troop_type TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          start_time INTEGER NOT NULL,
          end_time INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          FOREIGN KEY (village_id) REFERENCES villages (id)
        )
      ''');

      AppLogger.info('Criando tabela movements...');
      await db.execute('''
        CREATE TABLE movements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source_village_id INTEGER NOT NULL,
          target_village_id INTEGER NOT NULL,
          start_time INTEGER NOT NULL,
          arrival_time INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'moving',
          FOREIGN KEY (source_village_id) REFERENCES villages (id),
          FOREIGN KEY (target_village_id) REFERENCES villages (id)
        )
      ''');

      AppLogger.info('Criando tabela movement_troops...');
      await db.execute('''
        CREATE TABLE movement_troops (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          movement_id INTEGER NOT NULL,
          troop_type TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          FOREIGN KEY (movement_id) REFERENCES movements (id)
        )
      ''');

      AppLogger.info('Criando tabela battle_reports...');
      await db.execute('''
        CREATE TABLE battle_reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          movement_id INTEGER NOT NULL,
          attacker_village_id INTEGER NOT NULL,
          defender_village_id INTEGER NOT NULL,
          result TEXT NOT NULL,
          loot_wood INTEGER NOT NULL DEFAULT 0,
          loot_clay INTEGER NOT NULL DEFAULT 0,
          loot_iron INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (movement_id) REFERENCES movements (id),
          FOREIGN KEY (attacker_village_id) REFERENCES villages (id),
          FOREIGN KEY (defender_village_id) REFERENCES villages (id)
        )
      ''');

      AppLogger.info('Criando tabela game_meta...');
      await db.execute('''
        CREATE TABLE game_meta (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          last_opened_at INTEGER NOT NULL,
          last_sync_at INTEGER NOT NULL
        )
      ''');

      AppLogger.info('Todas as tabelas foram criadas com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar tabelas', e, stackTrace);
      rethrow;
    }
  }
}
