import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/html.dart' as html_parser;
import '../models/card_model.dart';

class YgoApiService {
  static const _baseUrl = 'https://db.ygoprodeck.com/api/v7';

  Future<YgoCard?> searchBySetCode(String setCode) async {
    try {
      final parts = setCode.toUpperCase().split('-');
      if (parts.length < 2) return null;
      final setPrefix = parts[0];
      final cardNum = parts.last.replaceAll(RegExp(r'[A-Z]'), '');

      final url = Uri.parse('$_baseUrl/cardinfo.php?cardset=${Uri.encodeComponent(setPrefix)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final cards = data['data'] as List<dynamic>;

      for (final cardJson in cards) {
        final card = YgoCard.fromJson(cardJson);
        final matching = card.variants.where((v) {
          final vNum = v.setCode.replaceAll(RegExp(r'[A-Z\-]'), '');
          return vNum == cardNum;
        }).toList();

        if (matching.isNotEmpty) {
          // Récupère le prix Cardmarket FR via scraping
          final setName = matching.first.setName;
          final price = await fetchCardmarketPrice(card.name, setName);
          for (final v in matching) { v.price = price ?? 0; }

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
      return null;
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

  Future<double?> fetchCardmarketPrice(String cardName, String setName) async {
    try {
      // Convertit les noms en format URL Cardmarket
      final setSlug = setName
          .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
          .trim()
          .split(' ')
          .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
          .join('-');

      final cardSlug = cardName
          .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
          .trim()
          .split(' ')
          .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
          .join('-');

      final url = Uri.parse(
        'https://www.cardmarket.com/fr/YuGiOh/Products/Singles/$setSlug/$cardSlug?language=2&minCondition=3'
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
        'Accept-Language': 'fr-FR,fr;q=0.9',
        'Accept': 'text/html,application/xhtml+xml',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final document = html_parser.parse(response.body);

      // Sélecteur du prix : span avec les classes Cardmarket
      final priceEl = document.querySelector(
        'span.color-primary.small.text-end.text-nowrap.fw-bold'
      );

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