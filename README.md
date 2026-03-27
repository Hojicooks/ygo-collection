# YGO Collection — App Flutter iOS

Gestionnaire de collection Yu-Gi-Oh avec scan OCR du code de set et prix Cardmarket FR.

---

## Installation sur Windows (PC de développement)

### 1. Installer Flutter
1. Télécharger Flutter SDK : https://docs.flutter.dev/get-started/install/windows
2. Extraire dans `C:\flutter`
3. Ajouter `C:\flutter\bin` au PATH Windows
4. Ouvrir un terminal et tester : `flutter doctor`

### 2. Installer VS Code
1. Télécharger VS Code : https://code.visualstudio.com
2. Installer l'extension **Flutter** (chercher "Flutter" dans les extensions)
3. Installer l'extension **Dart**

### 3. Ouvrir le projet
```bash
cd ygo_collection
flutter pub get
```

---

## Build iOS via MacInCloud

### 1. S'inscrire sur MacInCloud
- https://www.macincloud.com
- Plan "Pay As You Go" : ~1 €/heure (suffisant pour les builds)
- Ou plan mensuel ~25 €/mois si tu builds souvent

### 2. Préparer le build sur MacInCloud
Une fois connecté au Mac distant :

```bash
# Installer Flutter sur le Mac distant
git clone https://github.com/flutter/flutter.git ~/flutter
export PATH="$PATH:~/flutter/bin"
flutter doctor

# Copier ton projet (via upload MacInCloud ou GitHub)
git clone https://github.com/TON_COMPTE/ygo_collection.git
cd ygo_collection
flutter pub get

# Build iOS
flutter build ios --no-codesign
```

### 3. Installer sur iPhone via Xcode
1. Connecter l'iPhone en USB au Mac MacInCloud (via Remote USB ou copie IPA)
2. Ouvrir `ios/Runner.xcworkspace` dans Xcode
3. Sélectionner ton iPhone comme cible
4. Cliquer **Run** (▶)
5. Sur l'iPhone : Réglages → Général → VPN et gestion → Faire confiance à ton compte

---

## Permissions iOS requises

Dans `ios/Runner/Info.plist`, ces entrées sont nécessaires (normalement ajoutées automatiquement) :

```xml
<key>NSCameraUsageDescription</key>
<string>Nécessaire pour scanner les codes de set Yu-Gi-Oh</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Pour importer des photos de cartes</string>
```

---

## Structure du projet

```
lib/
├── main.dart                    # Point d'entrée + navigation
├── models/
│   └── card_model.dart          # YgoCard, CardVariant, InventoryCard
├── services/
│   ├── ygo_api_service.dart     # API YGOPRODeck + scraping Cardmarket
│   └── database_service.dart    # SQLite local (collection)
├── screens/
│   ├── scanner_screen.dart      # Caméra + OCR + recherche
│   └── inventory_screen.dart    # Liste collection + valeur totale
└── widgets/
    ├── rarity_picker_sheet.dart  # Popup sélection rareté
    └── card_result_widget.dart   # Affichage résultat scan
```

---

## Fonctionnement du scan

1. L'OCR (Google ML Kit) lit le texte visible sur la caméra en temps réel
2. Une regex filtre les codes de format `XXX-FRXXX` (ex: LOB-FR001)
3. L'API YGOPRODeck cherche la carte par son set
4. Si plusieurs raretés → popup de sélection avec prix Cardmarket par rareté
5. L'utilisateur confirme et la carte s'ajoute à la collection SQLite locale

---

## APIs utilisées

- **YGOPRODeck** (gratuite) : https://ygoprodeck.com/api-guide/
- **Cardmarket** (scraping) : https://www.cardmarket.com/fr/YuGiOh
  - Note : si le scraping est bloqué, l'app affiche le prix YGOPRODeck en fallback

---

## Prochaines améliorations possibles

- Export CSV de la collection
- Photos des cartes depuis la galerie
- Filtre par édition / rareté / valeur
- Graphique d'évolution des prix
- Sync iCloud pour backup
