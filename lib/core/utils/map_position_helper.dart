import 'package:imperio_tribal_app/core/utils/logger.dart';
import 'dart:math';

class MapPositionHelper {
  static const int mapSize = 7;
  static const int centerPosition = 3;

  // Gera uma posição aleatória no mapa (exceto o centro)
  static ({int x, int y}) generateRandomPosition() {
    try {
      final random = Random();
      int x, y;

      do {
        x = random.nextInt(mapSize);
        y = random.nextInt(mapSize);
      } while (x == centerPosition && y == centerPosition);

      AppLogger.info('Posição aleatória gerada: ($x, $y)');
      return (x: x, y: y);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao gerar posição aleatória', e, stackTrace);
      rethrow;
    }
  }

  // Gera uma lista de posições aleatórias únicas
  static List<({int x, int y})> generateUniquePositions(int count) {
    try {
      final positions = <({int x, int y})>{};

      while (positions.length < count) {
        positions.add(generateRandomPosition());
      }

      AppLogger.info('$count posições únicas geradas com sucesso');
      return positions.toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao gerar posições únicas', e, stackTrace);
      rethrow;
    }
  }

  // Verifica se uma posição é válida (dentro do mapa)
  static bool isValidPosition(int x, int y) {
    return x >= 0 && x < mapSize && y >= 0 && y < mapSize;
  }

  // Verifica se uma posição está no centro
  static bool isCenterPosition(int x, int y) {
    return x == centerPosition && y == centerPosition;
  }

  // Verifica se uma posição está ocupada
  static bool isPositionOccupied(
    List<({int x, int y})> occupiedPositions,
    int x,
    int y,
  ) {
    return occupiedPositions.any((pos) => pos.x == x && pos.y == y);
  }
}
