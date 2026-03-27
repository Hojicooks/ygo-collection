// lib/services/ygo_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_model.dart';

class YgoApiService {
  static const _baseUrl = 'https://db.ygoprodeck.com/api/v7';

  Future<YgoCard?> searchBySetCode(String setCode) async {
    try {
      // Recherche directement par code de set exact
      final url = Uri.parse('$_baseUrl/cardinfo.php?cardset=${Uri.encodeComponent(setCode)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final cards = data['data'] as List<dynamic>;
      if (cards.isEmpty) return null;

      // Cherche la carte dont un variant correspond au code exact
      for (final cardJson in cards) {
        final card = YgoCard.fromJson(cardJson);
        final matching = card.variants
            .where((v) => v.setCode.toUpperCase() == setCode.toUpperCase())
            .toList();
        if (matching.isNotEmpty) {
          return YgoCard(
            id: card.id,
            name: card.name,
            type: card.type,
            desc: card.desc,
            race: card.race,
            attribute: card.attribute,
            level: card.level,
            atk: card.atk,
            def: card.def,
            imageUrl: card.imageUrl,
            variants: matching,
          );
        }
      }

      // Fallback : retourne la première carte avec toutes ses variantes FR
      final first = YgoCard.fromJson(cards.first);
      final frVariants = first.variants
          .where((v) => v.setCode.toUpperCase().contains('FR'))
          .toList();
      return YgoCard(
        id: first.id,
        name: first.name,
        type: first.type,
        desc: first.desc,
        race: first.race,
        attribute: first.attribute,
        level: first.level,
        atk: first.atk,
        def: first.def,
        imageUrl: first.imageUrl,
        variants: frVariants.isNotEmpty ? frVariants : first.variants,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<YgoCard>> searchByName(String name) async {
    try {
      final url = Uri.parse('$_baseUrl/cardinfo.php?fname=${Uri.encodeComponent(name)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body);
      return (data['data'] as List<dynamic>)
          .take(10)
          .map((j) => YgoCard.fromJson(j))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Prix depuis YGOPRODeck (déjà inclus dans les variants)
  Future<double?> fetchCardmarketPrice(String cardName, String setCode) async {
    try {
      final url = Uri.parse('$_baseUrl/cardinfo.php?name=${Uri.encodeComponent(cardName)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      final cards = data['data'] as List<dynamic>;
      if (cards.isEmpty) return null;
      final card = YgoCard.fromJson(cards.first);
      final variant = card.variants
          .where((v) => v.setCode.toUpperCase() == setCode.toUpperCase())
          .firstOrNull;
      return variant?.price;
    } catch (e) {
      return null;
    }
  }
}