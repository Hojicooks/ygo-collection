# Guide complet — YGO Collection sur iPhone depuis Windows

---

## ÉTAPE 1 — Installer les outils sur ton PC Windows

### 1.1 Git
- Télécharger : https://git-scm.com/download/win
- Installer avec les options par défaut

### 1.2 Flutter SDK
- Télécharger : https://docs.flutter.dev/get-started/install/windows
- Extraire dans `C:\flutter`
- Ajouter `C:\flutter\bin` au PATH :
  - Chercher "Variables d'environnement" dans Windows
  - PATH → Modifier → Nouveau → `C:\flutter\bin`
- Tester dans un terminal : `flutter doctor`

### 1.3 VS Code
- Télécharger : https://code.visualstudio.com
- Installer les extensions : **Flutter** + **Dart**

---

## ÉTAPE 2 — Créer ton dépôt GitHub

1. Créer un compte gratuit sur https://github.com
2. Cliquer **New repository** → nommer `ygo-collection` → **Public** → **Create**
3. Sur ton PC, ouvrir un terminal dans le dossier du projet :

```bash
git init
git add .
git commit -m "Premier commit"
git branch -M main
git remote add origin https://github.com/TON_PSEUDO/ygo-collection.git
git push -u origin main
```

4. Aller sur GitHub → onglet **Actions** → tu verras le build démarrer automatiquement

---

## ÉTAPE 3 — Récupérer le fichier IPA

1. Sur GitHub, aller dans **Actions**
2. Cliquer sur le dernier build (vert = succès)
3. En bas de la page, section **Artifacts**
4. Télécharger **YGOCollection-IPA**
5. Extraire le ZIP → tu obtiens `YGOCollection.ipa`

---

## ÉTAPE 4 — Installer AltStore sur Windows + iPhone

### 4.1 Sur ton PC Windows
1. Télécharger AltServer (Windows) : https://altstore.io
2. Installer et lancer AltServer
3. Une icône apparaît dans la barre des tâches

### 4.2 Sur ton iPhone
1. Connecter l'iPhone au PC en USB
2. Faire confiance à l'ordinateur sur l'iPhone (appuyer "Faire confiance")
3. Ouvrir iTunes (ou installer si pas présent) — nécessaire pour qu'AltServer reconnaisse l'iPhone
4. Clic droit sur l'icône AltServer dans la barre des tâches
5. **Install AltStore** → sélectionner ton iPhone
6. Entrer ton identifiant Apple (compte gratuit suffit)
7. Sur l'iPhone : Réglages → Général → VPN et gestion → Faire confiance à ton compte

### 4.3 Installer l'IPA
1. Ouvrir AltStore sur l'iPhone
2. Onglet **My Apps** → `+` en haut à gauche
3. Sélectionner ton fichier `YGOCollection.ipa`
4. L'app s'installe !

---

## ÉTAPE 5 — Mettre à jour l'app (routine normale)

Chaque fois que tu modifies le code :

```bash
# Dans VS Code, terminal intégré :
git add .
git commit -m "Description de ta modification"
git push
```

→ GitHub compile automatiquement une nouvelle version
→ Tu télécharges le nouvel IPA
→ Tu l'installes via AltStore (remplace l'ancienne version)

---

## Re-signer tous les 7 jours (limitation Apple)

Avec un compte Apple gratuit, les apps installées via AltStore expirent après 7 jours.
Pour renouveler :

1. AltServer doit tourner sur ton PC
2. iPhone connecté en WiFi (même réseau que le PC)
3. Ouvrir AltStore sur l'iPhone → **Refresh All**

C'est tout ! Prend 30 secondes.

---

## Résumé du flow quotidien

```
Tu codes sur VS Code (Windows)
        ↓
git push
        ↓
GitHub compile sur Mac virtuel (automatique, gratuit)
        ↓
Tu télécharges le IPA
        ↓
AltStore installe sur ton iPhone
        ↓
Tu testes l'app !
```

---

## Problèmes fréquents

**"flutter doctor" signale des erreurs iOS**
→ Normal sur Windows, les erreurs iOS sont ignorables tant que tu utilises GitHub Actions pour compiler.

**AltServer ne voit pas l'iPhone**
→ Vérifier qu'iTunes est installé. Déconnecter/reconnecter le câble USB.

**Le build GitHub Actions échoue**
→ Aller dans l'onglet Actions → cliquer sur le build rouge → lire les logs.
→ La plupart du temps c'est un problème de dépendance, me partager l'erreur je t'aide.

**L'app expire au bout de 7 jours**
→ Lancer AltStore → Refresh All (PC allumé avec AltServer actif)
