# Império Tribal

**Império Tribal** é um jogo de estratégia e gestão de aldeias, inspirado em títulos clássicos de construção e expansão. Desenvolvido em Flutter com GetX para gerenciamento de estado, o jogo funciona 100% offline e aborda simulação de recursos, construções, tropas e batalhas.

## Visão Geral

- **Plataformas suportadas:** Android e iOS
- **Estado do jogo:** 100% offline, com persistência em SQLite.
- **Atualização periódica:** Processo de jogo é atualizado a cada 10 segundos em tempo real e também calculado ao reabrir o app.
- **Controle centralizado:** Um único `GameController` (GetX) gerencia:
  - Produção e coleta automática de recursos de todas as aldeias
  - Processamento de fila de upgrades de edifícios
  - Gerenciamento de tropas e treinamento
  - Movimentações e relatórios de batalhas

## Recursos Principais

1. **Criação de Jogador e Aldeia Inicial**

   - Cadastro de nome e seleção de tribo
   - Aldeia do jogador posicionada no centro do mapa (3,3)
   - Configuração inicial de recursos e construções básicas
   - Geração de aldeias NPC para interação estratégica

2. **Mapa e Navegação**

   - Grade 7×7 representando o território
   - Diferenciação visual entre aldeias próprias e NPCs
   - Tela de detalhe da aldeia com status de recursos, construções e fila de upgrades

3. **Produção de Recursos**

   - Madeira, Argila e Ferro produzidos com base nos níveis de edifícios
   - Limites de armazenamento definidos por nível de Armazém
   - Cálculo contínuo em intervalos de 10 segundos e recálculo offline ao reabrir

4. **Construções e Upgrades**

   - Vários tipos de edifícios: Town Hall, Armazém, Fazenda, Mina de Ferro, Poço de Argila, Bosque
   - Limite simultâneo de 3 upgrades e fila de espera
   - Tempo e custo de upgrades escaláveis por nível

5. **Tropas e Batalhas**

   - Dois tipos iniciais: Infantaria (Lanceiros e Espadachins) e Cavalaria (Leve e Pesada)
   - Fila de treinamento e gerenciamento de quantidade
   - Movimentação de tropas entre aldeias e relatórios de combate

6. **Persistência e Sincronização Offline**
   - Banco SQLite com tabelas para todas entidades do jogo
   - Registro de timestamp (`game_meta.last_opened_at`) para calcular tempo offline
   - Processamento de recursos, upgrades e treinamento durante inatividade

## Arquitetura de Estado

- **GetX**: Um `GameController` global inicializado na SplashScreen:

  - Carrega dados do banco
  - Processa progresso offline
  - Inicia loop periódico de 10 segundos
  - Disponibiliza RxLists e RxMaps para toda a UI

- **Repositórios**: Camada de acesso ao banco isolada, com métodos CRUD e upsert para:
  - Users, Villages, Resources, Buildings, Upgrades, Troops, Movements e metadados

## Próximos Passos

- Implementação de eventos especiais e achievements
- Otimização de performance e balanceamento de mecânicas
- Introdução de multiplayer assíncrono ou rankings online (futuro)

---

#tabelas
users
villages
resources
buildings
upgrades_queue
troops
training_queue
movements
movement_troops
battle_reports

> Desenvolvido com Flutter, GetX e SQLite — o jogo que desafia sua estratégia mesmo quando está offline.
