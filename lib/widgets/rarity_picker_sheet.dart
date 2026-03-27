// lib/widgets/rarity_picker_sheet.dart

import 'package:flutter/material.dart';
import '../models/card_model.dart';

class RarityPickerSheet extends StatelessWidget {
  final YgoCard card;
  final ValueChanged<CardVariant> onSelected;

  const RarityPickerSheet({
    super.key,
    required this.card,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plusieurs variantes trouvées',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${card.variants.length} raretés pour ${card.name} — choisissez la vôtre',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Infos de la carte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (card.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      card.imageUrl!,
                      width: 44,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _CardPlaceholder(),
                    ),
                  )
                else
                  const _CardPlaceholder(),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      card.type,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 24),

          // Liste des raretés
          ...card.variants.map((variant) => _RarityItem(
                variant: variant,
                onTap: () {
                  Navigator.pop(context);
                  onSelected(variant);
                },
              )),

          // Bouton annuler
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white54,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Annuler'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RarityItem extends StatelessWidget {
  final CardVariant variant;
  final VoidCallback onTap;

  const _RarityItem({required this.variant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Point de couleur rareté
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: variant.rarityColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.rarity,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    variant.setCode,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            // Prix
            Text(
              variant.price != null && variant.price! > 0
                  ? '${variant.price!.toStringAsFixed(2)} €'
                  : '— €',
              style: const TextStyle(
                  color: Color(0xFF2D9E6A), fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF5340C9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.style, color: Colors.white60, size: 22),
    );
  }
}
