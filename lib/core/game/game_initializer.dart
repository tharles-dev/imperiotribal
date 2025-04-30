import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'package:imperio_tribal_app/core/utils/map_position_helper.dart';
import 'package:imperio_tribal_app/data/models/user_model.dart';
import 'package:imperio_tribal_app/data/models/village_model.dart';
import 'package:imperio_tribal_app/data/models/resource_model.dart';
import 'package:imperio_tribal_app/data/repositories/user_repository.dart';
import 'package:imperio_tribal_app/data/repositories/village_repository.dart';
import 'package:imperio_tribal_app/data/repositories/resource_repository.dart';
import 'package:imperio_tribal_app/data/repositories/building_repository.dart';
import 'package:imperio_tribal_app/core/constants/production_rates.dart';

class GameInitializer {
  final _userRepository = UserRepository();
  final _villageRepository = VillageRepository();
  final _resourceRepository = ResourceRepository();
  final _buildingRepository = BuildingRepository();

  // Cria o usuário principal e sua aldeia inicial
  Future<UserModel> createMainUser({
    required String name,
    required String tribe,
    required DateTime createdAt,
  }) async {
    try {
      AppLogger.info('Criando usuário principal: $name');

      // Cria o usuário principal
      final user = UserModel(
        name: name,
        tribe: tribe,
        isNpc: false,
        createdAt: createdAt,
      );
      final userId = await _userRepository.create(user);

      // Cria a aldeia principal no centro
      final village = VillageModel(
        userId: userId,
        name: '$name Village',
        x: MapPositionHelper.centerPosition,
        y: MapPositionHelper.centerPosition,
        createdAt: createdAt,
      );
      final villageId = await _villageRepository.create(village);

      // Cria os recursos iniciais com produção base
      final resources = ResourceModel(
        villageId: villageId,
        wood: 200,
        clay: 200,
        iron: 200,
        woodProduction: ProductionRates.woodcutterBaseRate,
        clayProduction: ProductionRates.clayPitBaseRate,
        ironProduction: ProductionRates.ironMineBaseRate,
        lastUpdatedAt: createdAt,
      );
      await _resourceRepository.create(resources);

      // Cria os edifícios iniciais
      await _buildingRepository.createInitialBuildings(
        villageId,
        createdAt.millisecondsSinceEpoch,
      );

      AppLogger.info('Usuário principal e aldeia criados com sucesso');
      return user.copyWith(id: userId);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar usuário principal', e, stackTrace);
      rethrow;
    }
  }

  // Cria os NPCs e suas aldeias
  Future<void> createNpcs(DateTime createdAt) async {
    try {
      AppLogger.info('Criando NPCs e suas aldeias');
      final npcNames = ['Barbarian', 'Roman', 'Teuton', 'Gaul', 'Egyptian'];
      final npcTribes = ['Barbarian', 'Roman', 'Teuton', 'Gaul', 'Egyptian'];

      // Gera posições únicas para as aldeias NPC
      final positions = MapPositionHelper.generateUniquePositions(
        npcNames.length,
      );

      for (var i = 0; i < npcNames.length; i++) {
        // Cria o usuário NPC
        final npc = UserModel(
          name: npcNames[i],
          tribe: npcTribes[i],
          isNpc: true,
          createdAt: createdAt,
        );
        final npcId = await _userRepository.create(npc);

        // Cria a aldeia NPC
        final village = VillageModel(
          userId: npcId,
          name: '${npcNames[i]} Village',
          x: positions[i].x,
          y: positions[i].y,
          createdAt: createdAt,
        );
        final villageId = await _villageRepository.create(village);

        // Cria os recursos iniciais com produção base
        final resources = ResourceModel(
          villageId: villageId,
          wood: 200,
          clay: 200,
          iron: 200,
          woodProduction: ProductionRates.woodcutterBaseRate,
          clayProduction: ProductionRates.clayPitBaseRate,
          ironProduction: ProductionRates.ironMineBaseRate,
          lastUpdatedAt: createdAt,
        );
        await _resourceRepository.create(resources);

        // Cria os edifícios iniciais
        await _buildingRepository.createInitialBuildings(
          villageId,
          createdAt.millisecondsSinceEpoch,
        );
      }

      AppLogger.info('NPCs e aldeias criados com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar NPCs', e, stackTrace);
      rethrow;
    }
  }

  // Inicializa o jogo completo
  Future<UserModel> initializeGame({
    required String name,
    required String tribe,
    required DateTime createdAt,
  }) async {
    try {
      AppLogger.info('Iniciando jogo para: $name');

      // Cria usuário principal e sua aldeia
      final user = await createMainUser(
        name: name,
        tribe: tribe,
        createdAt: createdAt,
      );

      // Cria NPCs e suas aldeias
      await createNpcs(createdAt);

      AppLogger.info('Jogo inicializado com sucesso');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao inicializar jogo', e, stackTrace);
      rethrow;
    }
  }
}
