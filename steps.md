# Império Tribal - Passos do Desenvolvimento

## Sistema de Construções

### 1. Estrutura Base do Sistema

- Implementação do `BuildingQueueManager` para gerenciar construções
  - Processamento de filas de construção
  - Verificação de construções concluídas
  - Atualização de níveis dos edifícios
  - Recálculo de produção de recursos

### 2. Modelos e Repositórios

- Criação do `UpgradeQueueModel` para representar construções na fila
- Implementação do `UpgradeQueueRepository` para operações no banco
- Adição do método `copyWith` ao `BuildingModel`
- Definição dos tipos de edifícios no enum `BuildingType`
  - warehouse (Armazém)
  - woodcutter (Lenhador)
  - clayPit (Poço de Argila)
  - ironMine (Mina de Ferro)
  - townHall (Centro da Vila)
  - farm (Fazenda)
  - barracks (Quartel)
  - stable (Estábulo)

### 3. Integração com GameController

- Processamento paralelo de recursos e construções
- Loop de atualização a cada 10 segundos
- Gerenciamento do estado do app (ativo/inativo)
- Tratamento de erros e logging

### 4. Interface do Usuário

#### 4.1 Componentes Principais

- `VillageBuildings`: Widget principal que organiza a tela
  - Seção de Construções em Andamento
  - Seção de Edifícios Disponíveis
  - Seção de Edifícios Bloqueados
  - Pull-to-refresh para atualização

#### 4.2 Componentes Específicos

- `BuildingUpgradeQueue`: Exibe construções em andamento

  - Lista de construções atuais
  - Tempo restante
  - Estado da construção

- `AvailableBuildings`: Lista edifícios disponíveis

  - Verificação de recursos
  - Cálculo de custos
  - Tempo de construção
  - Botão de upgrade

- `LockedBuildings`: Mostra edifícios bloqueados

  - Requisitos de nível
  - Razão do bloqueio
  - Custos futuros

- `BuildingItem`: Componente base reutilizável
  - Nome traduzido do edifício
  - Nível atual
  - Custos de recursos
  - Tempo de construção
  - Estados visuais (bloqueado/construindo/disponível)

### 5. Constantes e Configurações

- `BuildingConstants`: Classe para gerenciar constantes
  - Níveis máximos por edifício
  - Custos base de construção
  - Multiplicadores de custo e tempo
  - Requisitos de nível entre edifícios
  - Cálculos de tempo e custo de construção

### 6. Melhorias de UX

- Interface traduzida para português
- Feedback visual para ações do usuário
- Indicadores de loading
- Tratamento de erros com mensagens amigáveis
- Estados visuais claros para diferentes situações

### 7. Integração com VillageScreen

- Atualização da tela principal da aldeia
  - Remoção do conteúdo placeholder
  - Adição de scroll para conteúdo extenso
  - Integração com sistema de recursos
  - Integração completa do sistema de construções
  - Estilização consistente com o tema do jogo

### 8. Próximos Passos

- Implementar sistema de produção de recursos
- Adicionar sistema de tropas
- Desenvolver mecânica de combate
- Implementar sistema de missões
- Adicionar sistema de rankings
