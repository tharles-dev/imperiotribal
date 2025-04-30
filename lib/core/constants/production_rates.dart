class ProductionRates {
  // Taxas base de produção por nível
  static const int woodcutterBaseRate = 5;
  static const int clayPitBaseRate = 5;
  static const int ironMineBaseRate = 5;

  // Calcula a produção de madeira baseada no nível
  static int calculateWoodProduction(int level) {
    return woodcutterBaseRate * level;
  }

  // Calcula a produção de argila baseada no nível
  static int calculateClayProduction(int level) {
    return clayPitBaseRate * level;
  }

  // Calcula a produção de ferro baseada no nível
  static int calculateIronProduction(int level) {
    return ironMineBaseRate * level;
  }
}
