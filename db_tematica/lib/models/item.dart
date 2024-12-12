class Item {
  final String id;
  final String image;
  final String name;
  final String description;
  final int damage;
  final bool autoAttack;
  final int knockback;
  final int critChance;
  final int useTime;
  final int buyPrice;
  final int sellPrice;
  final String createdWith;
  final String updatedAt;
  final String category;

  Item({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.damage,
    required this.autoAttack,
    required this.knockback,
    required this.critChance,
    required this.useTime,
    required this.buyPrice,
    required this.sellPrice,
    required this.createdWith,
    required this.updatedAt,
    required this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      image: json['image'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      damage: json['damage'] as int,
      autoAttack: json['autoAttack'] as bool,
      knockback: json['knockback'] as int,
      critChance: json['critChance'] as int,
      useTime: json['useTime'] as int,
      buyPrice: json['buyPrice'] as int,
      sellPrice: json['sellPrice'] as int,
      createdWith: json['createdWith'] as String,
      updatedAt: json['updatedAt'] as String,
      category: json['category'] as String,
    );
  }
} 