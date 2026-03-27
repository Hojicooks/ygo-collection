// lib/widgets/card_result_widget.dart

import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardResultWidget extends StatelessWidget {
  final YgoCard card;
  final CardVariant? selectedVariant;
  final VoidCallback onPickRarity;
  final VoidCallback onAdd;

  const CardResultWidget({
    super.key,
    required this.card,
    required this.selectedVariant,
    required this.onPickRarity,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Infos carte
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (card.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      card.imageUrl!,
                      width: 56,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 56,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5340C9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.style, color: Colors.white60),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(card.type,
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      // Tags FR + rareté
                      Wrap(
                        spacing: 6,
                        children: [
                          _Tag(label: 'FR', color: const Color(0xFF1E40AF), bg: const Color(0xFF1E3A8A).withOpacity(0.3)),
                          if (selectedVariant != null)
                            _Tag(
                              label: selectedVariant!.rarity,
                              color: selectedVariant!.rarityColor,
                              bg: selectedVariant!.rarityColor.withOpacity(0.15),
                            )
                          else
                            GestureDetector(
                              onTap: onPickRarity,
                              child: _Tag(
                                label: '${card.variants.length} raretés →',
                                color: const Color(0xFF7C6CF5),
                                bg: const Color(0xFF5340C9).withOpacity(0.2),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Prix
                      if (selectedVariant != null)
                        Row(
                          children: [
                            Text(
                              selectedVariant!.price != null && selectedVariant!.price! > 0
                                  ? '${selectedVariant!.price!.toStringAsFixed(2)} €'
                                  : '— €',
                              style: const TextStyle(
                                  color: Color(0xFF2D9E6A), fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 6),
                            const Text('Cardmarket (moyen FR)',
                                style: TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          const Divider(color: Colors.white12, height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: selectedVariant != null ? onAdd : onPickRarity,
                  child: Text(
                    selectedVariant != null ? '+ Ajouter à la collection' : 'Choisir la rareté',
                    style: const TextStyle(color: Color(0xFF7C6CF5), fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _Tag({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
