abstract class Card {
  final String id;
  final String name;
  final String imageAsset;

  Card({
    required this.id,
    required this.name,
    required this.imageAsset,
  });
}

class AssetCard extends Card {
  final int starLevel;
  final int cost;
  final int cpOnPurchase;
  final int cpPerRound;
  final int incomePerRound;
  final int debtUpkeep;

  AssetCard({
    required super.id,
    required super.name,
    required this.starLevel,
    required this.cost,
    required this.cpOnPurchase,
    required this.cpPerRound,
    required this.incomePerRound,
    required this.debtUpkeep,
    required super.imageAsset,
  });
}

class EventCard extends Card {
  final String description;
  final int phase;
  final Function(List<dynamic>) effect;

  EventCard({
    required super.id,
    required super.name,
    required this.description,
    required this.phase,
    required this.effect,
    required super.imageAsset,
  });
}

class LifeCard extends Card {
  final String description;
  final Function(dynamic) effect;

  LifeCard({
    required super.id,
    required super.name,
    required this.description,
    required this.effect,
    required super.imageAsset,
  });
}

class AvatarCard extends Card {
  final int startingCp;
  final int startingDebt;
  final int startingIncome;
  final String ability;

  AvatarCard({
    required super.id,
    required super.name,
    required this.startingCp,
    required this.startingDebt,
    required this.startingIncome,
    required this.ability,
    required super.imageAsset,
  });
}
