class ProductionRates {
  // Taxas de produção base por segundo para cada edifício no nível 1
  static const int woodcutterBaseRate = 2; // 5 madeira por segundo
  static const int clayPitBaseRate = 2; // 4 argila por segundo
  static const int ironMineBaseRate = 2; // 3 ferro por segundo

  // Fórmula para calcular a produção base de um edifício
  static int calculateBaseProduction(String buildingType) {
    switch (buildingType) {
      case 'woodcutter':
        return woodcutterBaseRate;
      case 'clay_pit':
        return clayPitBaseRate;
      case 'iron_mine':
        return ironMineBaseRate;
      default:
        return 0;
    }
  }
}
