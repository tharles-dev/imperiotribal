# Implementação do Sistema de Tropas

## 1. Modelos de Dados

### 1.1 Tipos de Tropas

```dart
enum TroopType {
  spearman,    // Lanceiro (Infantaria)
  swordsman,   // Espadachim (Infantaria)
  lightCavalry, // Cavalaria Leve
  heavyCavalry, // Cavalaria Pesada
}
```

### 1.2 Modelo de Tropa

```dart
class TroopModel {
  final int? id;
  final int villageId;
  final String type; // TroopType.name
  final int quantity;
  final int createdAt;
}
```

### 1.3 Modelo de Fila de Treinamento

```dart
class TrainingQueueModel {
  final int? id;
  final int villageId;
  final String troopType;
  final int quantity;
  final int startTime;
  final int endTime;
}
```

## 2. Constantes e Cálculos

### 2.1 Custo de Treinamento por Nível

```dart
class TroopConstants {
  static Map<String, Map<String, int>> getTrainingCost(TroopType type, int barracksLevel) {
    switch (type) {
      case TroopType.spearman:
        return {
          'wood': 50 * barracksLevel,
          'clay': 30 * barracksLevel,
          'iron': 10 * barracksLevel,
        };
      case TroopType.swordsman:
        return {
          'wood': 30 * barracksLevel,
          'clay': 30 * barracksLevel,
          'iron': 70 * barracksLevel,
        };
      // ... outros tipos
    }
  }

  static int getTrainingTime(TroopType type, int barracksLevel) {
    switch (type) {
      case TroopType.spearman:
        return 60 * barracksLevel; // segundos
      case TroopType.swordsman:
        return 90 * barracksLevel;
      // ... outros tipos
    }
  }
}
```

### 2.2 Capacidade de População

```dart
class FarmConstants {
  static int getPopulationCapacity(int farmLevel) {
    return 100 + (farmLevel * 50);
  }
}
```

## 3. Implementação

### 3.1 Repositórios

#### 3.1.1 TroopRepository

```dart
class TroopRepository {
  Future<List<TroopModel>> findByVillageId(int villageId);
  Future<void> create(TroopModel troop);
  Future<void> update(TroopModel troop);
  Future<void> delete(int troopId);
}
```

#### 3.1.2 TrainingQueueRepository

```dart
class TrainingQueueRepository {
  Future<List<TrainingQueueModel>> findByVillageId(int villageId);
  Future<void> create(TrainingQueueModel training);
  Future<void> delete(int trainingId);
}
```

### 3.2 Controllers

#### 3.2.1 VillageTroopsController

```dart
class VillageTroopsController extends GetxController {
  final RxList<TroopModel> troops = <TroopModel>[].obs;
  final RxList<TrainingQueueModel> trainingQueue = <TrainingQueueModel>[].obs;
  final RxInt population = 0.obs;
  final RxInt maxPopulation = 0.obs;

  // Métodos principais
  Future<void> loadTroops(int villageId);
  Future<bool> startTraining(TroopType type, int quantity);
  Future<void> cancelTraining(int trainingId);
  Future<int> getAvailablePopulation();
}
```

### 3.3 Widgets

#### 3.3.1 TrainingQueueWidget

- Mostra tropas em treinamento
- Progresso do treinamento
- Botão para cancelar

#### 3.3.2 AvailableTroopsWidget

- Lista tropas disponíveis
- Quantidade de cada tipo
- Botão para treinar mais

#### 3.3.3 TrainingDialog

- Seleção de tipo de tropa
- Quantidade a treinar
- Custo total
- Tempo total
- Botão confirmar/cancelar

## 4. Fluxo de Implementação

1. **Criar Modelos e Constantes**

   - Implementar modelos de dados
   - Definir constantes de custo e tempo
   - Criar tabelas no banco

2. **Implementar Repositórios**

   - Criar métodos CRUD
   - Implementar queries específicas
   - Adicionar logging

3. **Criar Controllers**

   - Implementar lógica de negócio
   - Gerenciar estado
   - Adicionar validações

4. **Desenvolver Widgets**

   - Criar interface de treinamento
   - Implementar fila de treinamento
   - Adicionar feedback visual

5. **Integrar com Sistema Existente**
   - Conectar com recursos
   - Integrar com construções
   - Atualizar interface

## 5. Regras de Negócio

1. **Limites de População**

   - Capacidade base: 100
   - +50 por nível da Fazenda
   - População atual = Soma de todas as tropas

2. **Requisitos de Construções**

   - Quartel nível 1: Lanceiros
   - Quartel nível 3: Espadachins
   - Quartel nível 5: Cavalaria Leve
   - Quartel nível 7: Cavalaria Pesada

3. **Custos e Tempos**

   - Custo aumenta com nível do Quartel
   - Tempo diminui com nível do Quartel
   - Máximo de 3 treinamentos simultâneos

4. **Validações**
   - Recursos suficientes
   - População disponível
   - Slot de treinamento livre
   - Nível do Quartel adequado

## 6. Próximos Passos

1. Implementar sistema de batalhas
2. Adicionar movimentação de tropas
3. Criar relatórios de combate
4. Balancear custos e tempos
5. Adicionar efeitos visuais
