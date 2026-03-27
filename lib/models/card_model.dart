// lib/models/card_model.dart

import 'package:flutter/material.dart';

class YgoCard {
  final int id;
  final String name;
  final String type;
  final String? desc;
  final String? race;
  final String? attribute;
  final int? level;
  final int? atk;
  final int? def;
  final String? imageUrl;
  final List<CardVariant> variants;

  YgoCard({
    required this.id,
    required this.name,
    required this.type,
    this.desc,
    this.race,
    this.attribute,
    this.level,
    this.atk,
    this.def,
    this.imageUrl,
    required this.variants,
  });

  factory YgoCard.fromJson(Map<String, dynamic> json) {
    final sets = (json['card_sets'] as List<dynamic>? ?? [])
        .map((s) => CardVariant.fromJson(s))
        .toList();
    return YgoCard(
      id: json['id'],
      name: json['name'],
      type: json['type'] ?? '',
      desc: json['desc'],
      race: json['race'],
      attribute: json['attribute'],
      level: json['level'],
      atk: json['atk'],
      def: json['def'],
      imageUrl: json['card_images']?[0]?['image_url_small'],
      variants: sets,
    );
  }
}

class CardVariant {
  final String setCode;
  final String setName;
  final String rarity;
  final String rarityCode;
  double? price;

  CardVariant({
    required this.setCode,
    required this.setName,
    required this.rarity,
    required this.rarityCode,
    this.price,
  });

  factory CardVariant.fromJson(Map<String, dynamic> json) {
    return CardVariant(
      setCode: json['set_code'] ?? '',
      setName: json['set_name'] ?? '',
      rarity: json['set_rarity'] ?? '',
      rarityCode: json['set_rarity_code'] ?? '',
      price: double.tryParse(json['set_price']?.toString() ?? '0'),
    );
  }

  Color get rarityColor {
    switch (rarityCode.toUpperCase()) {
      case 'SCR': return const Color(0xFFD4537E);
      case 'UR':  return const Color(0xFF5340C9);
      case 'SR':  return const Color(0xFF1D9E75);
      case 'R':   return const Color(0xFFBA7517);
      default:    return const Color(0xFF888780);
    }
  }
}

class InventoryCard {
  final int? dbId;
  final int ygoId;
  final String name;
  final String type;
  final String setCode;
  final String setName;
  final String rarity;
  final String rarityCode;
  final double price;
  final String? imageUrl;
  final DateTime addedAt;
  final String? note;

  InventoryCard({
    this.dbId,
    required this.ygoId,
    required this.name,
    required this.type,
    required this.setCode,
    required this.setName,
    required this.rarity,
    required this.rarityCode,
    required this.price,
    this.imageUrl,
    required this.addedAt,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'ygo_id': ygoId,
    'name': name,
    'type': type,
    'set_code': setCode,
    'set_name': setName,
    'rarity': rarity,
    'rarity_code': rarityCode,
    'price': price,
    'image_url': imageUrl,
    'added_at': addedAt.toIso8601String(),
    'note': note,
  };

  factory InventoryCard.fromMap(Map<String, dynamic> map) => InventoryCard(
    dbId: map['id'],
    ygoId: map['ygo_id'],
    name: map['name'],
    type: map['type'],
    setCode: map['set_code'],
    setName: map['set_name'],
    rarity: map['rarity'],
    rarityCode: map['rarity_code'],
    price: (map['price'] as num).toDouble(),
    imageUrl: map['image_url'],
    addedAt: DateTime.parse(map['added_at']),
    note: map['note'],
  );
}
