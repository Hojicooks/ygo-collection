// lib/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/database_service.dart';
import '../models/card_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _db = DatabaseService();
  List<InventoryCard> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cards = await _db.getAllCards();
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  double get _total => _cards.fold(0, (s, c) => s + c.price);

  Future<void> _delete(InventoryCard card) async {
    if (card.dbId == null) return;
    await _db.deleteCard(card.dbId!);
    await _load();
  }

  Color _rarityColor(String rarityCode) {
    switch (rarityCode.toUpperCase()) {
      case 'SCR': return const Color(0xFFD4537E);
      case 'UR':  return const Color(0xFF5340C9);
      case 'SR':  return const Color(0xFF1D9E75);
      case 'R':   return const Color(0xFFBA7517);
      default:    return const Color(0xFF888780);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Ma collection', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_cards.length} cartes',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6CF5)))
          : _cards.isEmpty
              ? const Center(
                  child: Text('Aucune carte dans la collection.\nScannez votre première carte !',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 14)),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          itemCount: _cards.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: Colors.white10, height: 1),
                          itemBuilder: (_, i) {
                            final card = _cards[i];
                            return Dismissible(
                              key: Key(card.dbId.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: const Color(0xFFA32D2D),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              onDismissed: (_) => _delete(card),
                              child: _CardRow(card: card, rarityColor: _rarityColor(card.rarityCode)),
                            );
                          },
                        ),
                      ),
                    ),
                    // Barre total
                    Container(
                      color: const Color(0xFF1A1A2E),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Valeur estimée totale',
                              style: TextStyle(color: Colors.white54, fontSize: 12)),
                          Text(
                            '${_total.toStringAsFixed(2)} €',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final InventoryCard card;
  final Color rarityColor;

  const _CardRow({required this.card, required this.rarityColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: card.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: card.imageUrl!,
                    width: 40,
                    height: 58,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const _Placeholder(),
                    errorWidget: (_, __, ___) => const _Placeholder(),
                  )
                : const _Placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: rarityColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(card.rarity,
                          style: TextStyle(color: rarityColor, fontSize: 10)),
                    ),
                    const SizedBox(width: 6),
                    Text(card.setCode,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10, fontFamily: 'monospace')),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${card.price.toStringAsFixed(2)} €',
            style: const TextStyle(
                color: Color(0xFF2D9E6A), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 58,
        color: const Color(0xFF5340C9),
        child: const Icon(Icons.style, color: Colors.white38, size: 18),
      );
}
