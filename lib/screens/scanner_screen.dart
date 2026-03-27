// lib/screens/scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import '../services/ygo_api_service.dart';
import '../services/database_service.dart';
import '../models/card_model.dart';
import '../widgets/rarity_picker_sheet.dart';
import '../widgets/card_result_widget.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _cameraController;
  final _apiService = YgoApiService();
  final _dbService = DatabaseService();
  final _searchController = TextEditingController();

  bool _isScanning = false;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  String? _lastDetectedCode;
  YgoCard? _foundCard;
  CardVariant? _selectedVariant;
  String? _errorMessage;

  // Regex: LOB-FR001, SDK-FR023, SDMA-FR016...
  final _setCodeRegex = RegExp(r'\b[A-Z]{2,6}-FR\d{3}\b', caseSensitive: false);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() => _isCameraReady = true);
  }

  // Lance le scan OCR sur une image de la caméra
  Future<void> _captureAndScan() async {
  if (_isProcessing || _cameraController == null) return;
  setState(() { _isProcessing = true; _errorMessage = null; });

  try {
    final image = await _cameraController!.takePicture();
    // OCR via flutter_vision
    final FlutterVision vision = FlutterVision();
    await vision.startOcrOnImage(
      imagePath: image.path,
      language: 'fra',
    );
    final result = await vision.getOcrResult();
    final text = result.map((r) => r['text']).join(' ');
    
    final match = _setCodeRegex.firstMatch(text.toUpperCase());
    if (match != null) {
      await _searchCard(match.group(0)!);
    } else {
      setState(() => _errorMessage = 'Aucun code de set détecté. Essayez de vous rapprocher.');
    }
  } finally {
    setState(() => _isProcessing = false);
  }
}

  // Recherche une carte par code
  Future<void> _searchCard(String code) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _foundCard = null;
      _selectedVariant = null;
    });

    final card = await _apiService.searchBySetCode(code.toUpperCase());

    if (card == null) {
      setState(() => _errorMessage = 'Carte "$code" non trouvée.');
      setState(() => _isProcessing = false);
      return;
    }

    // Récupère les prix Cardmarket pour chaque variante
    for (final variant in card.variants) {
      final price = await _apiService.fetchCardmarketPrice(card.name, variant.setCode);
      if (price != null) variant.price = price;
    }

    setState(() {
      _foundCard = card;
      _isProcessing = false;
    });

    // Si une seule rareté → sélection auto, sinon popup
    if (card.variants.length == 1) {
      setState(() => _selectedVariant = card.variants.first);
    } else {
      _showRarityPicker(card);
    }
  }

  void _showRarityPicker(YgoCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RarityPickerSheet(
        card: card,
        onSelected: (variant) {
          setState(() => _selectedVariant = variant);
        },
      ),
    );
  }

  Future<void> _addToInventory() async {
    if (_foundCard == null || _selectedVariant == null) return;

    final entry = InventoryCard(
      ygoId: _foundCard!.id,
      name: _foundCard!.name,
      type: _foundCard!.type,
      setCode: _selectedVariant!.setCode,
      setName: _selectedVariant!.setName,
      rarity: _selectedVariant!.rarity,
      rarityCode: _selectedVariant!.rarityCode,
      price: _selectedVariant!.price ?? 0,
      imageUrl: _foundCard!.imageUrl,
      addedAt: DateTime.now(),
    );

    await _dbService.addCard(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_foundCard!.name} (${_selectedVariant!.rarity}) ajoutée !'),
        backgroundColor: const Color(0xFF2D7A4F),
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        _foundCard = null;
        _selectedVariant = null;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            // Viewfinder caméra
            Expanded(
              flex: 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isCameraReady && _cameraController != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CameraPreview(_cameraController!),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFF7C6CF5)),
                      ),
                    ),
                  // Cadre de scan
                  Container(
                    width: 260,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF7C6CF5), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Texte hint
                  Positioned(
                    bottom: 30,
                    child: Text(
                      'Centrez le code de set (ex: LOB-FR001)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contrôles
            Container(
              color: const Color(0xFF0D0D1A),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Bouton scan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _captureAndScan,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.camera_alt),
                      label: Text(_isProcessing ? 'Analyse en cours…' : 'Scanner le code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5340C9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Recherche manuelle
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Code manuel (ex: LOB-FR001)…',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFF1A1A2E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: _searchCard,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _searchCard(_searchController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5340C9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        ),
                        child: const Text('OK'),
                      ),
                    ],
                  ),

                  // Message d'erreur
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 13)),
                    ),

                  // Résultat de la carte
                  if (_foundCard != null)
                    CardResultWidget(
                      card: _foundCard!,
                      selectedVariant: _selectedVariant,
                      onPickRarity: () => _showRarityPicker(_foundCard!),
                      onAdd: _addToInventory,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
