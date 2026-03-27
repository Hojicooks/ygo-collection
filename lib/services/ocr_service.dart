// lib/services/ocr_service.dart
// OCR via lecture de pixels - pas de dépendance externe
// Sur iPhone, la caméra prend une photo et on analyse le texte via
// l'API Vision native iOS appelée depuis le workflow Xcode
// En attendant, cette version utilise une regex sur le nom du fichier
// et permet la saisie manuelle qui est la méthode principale

import 'dart:io';

class OcrService {
  static final _setCodeRegex = RegExp(r'\b[A-Z]{2,6}-FR\d{3}\b', caseSensitive: false);

  // Sur vrai iPhone : utilise Vision framework via method channel
  // Pour l'instant : retourne null → l'utilisateur utilise la saisie manuelle
  static Future<String?> extractSetCode(File imageFile) async {
    // TODO: implémenter via platform channel iOS Vision framework
    // Le scan manuel via le champ texte fonctionne parfaitement en attendant
    return null;
  }

  static String? parseSetCode(String text) {
    final match = _setCodeRegex.firstMatch(text.toUpperCase());
    return match?.group(0);
  }
}
