// lib/services/ygo_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/card_model.dart';

class YgoApiService {
  static const _baseUrl = 'https://db.ygoprodeck.com/api/v7';

  // Recherche par code de set (ex: LOB-FR001)
  Future<YgoCard?> searchBySetCode(String setCode) async {
    try {
      // Normalise le code: LOB-FR001 → LOB-EN001 pour l'API (puis on filtre FR)
      final url = Uri.parse('$_baseUrl/cardinfo.php?cardset=${_extractSetName(setCode)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final cards = (data['data'] as List<dynamic>);

      // Cherche la carte dont un set_code correspond exactement
      for (final cardJson in cards) {
        final card = YgoCard.fromJson(cardJson);
        // Filtre uniquement les variantes FR correspondant au code scanné
        final frVariants = card.variants
            .where((v) => v.setCode.toUpperCase() == setCode.toUpperCase())
            .toList();
        if (frVariants.isNotEmpty) {
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
            variants: frVariants,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Recherche par nom (fallback recherche manuelle)
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

  // Extrait le nom du set depuis le code (LOB-FR001 → LOB)
  String _extractSetName(String setCode) {
    return setCode.split('-').first;
  }

  // Récupère le prix depuis Cardmarket (scraping page FR)
  Future<double?> fetchCardmarketPrice(String cardName, String setCode) async {
    try {
      // Formatage du nom pour l'URL Cardmarket
      final slug = cardName
          .toLowerCase()
          .replaceAll(RegExp(r"[''']"), '')
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'-+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');

      final setSlug = setCode.split('-').first.toLowerCase();

      final url = Uri.parse(
          'https://www.cardmarket.com/fr/YuGiOh/Products/Singles/$setSlug/$slug');

      final response = await http.get(url, headers: {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
        'Accept-Language': 'fr-FR,fr;q=0.9',
      }).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return null;

      final document = html_parser.parse(response.body);

      // Sélecteur du prix moyen sur la page produit Cardmarket
      final priceEl = document.querySelector('.avg-price') ??
          document.querySelector('[data-testid="price-trend"]') ??
          document.querySelector('.price-container .font-weight-bold');

      if (priceEl == null) return null;

      final priceText = priceEl.text
          .replaceAll(RegExp(r'[^\d,.]'), '')
          .replaceAll(',', '.');

      return double.tryParse(priceText);
    } catch (e) {
      return null;
    }
  }
}
