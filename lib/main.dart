// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/scanner_screen.dart';
import 'screens/inventory_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YgoCollectionApp());
}

class YgoCollectionApp extends StatelessWidget {
  const YgoCollectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YGO Collection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5340C9),
          surface: const Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    ScannerScreen(),
    InventoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A1A2E),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: const Color(0xFF5340C9).withOpacity(0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.qr_code_scanner, color: Color(0xFF7C6CF5)),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.list_alt, color: Color(0xFF7C6CF5)),
            label: 'Collection',
          ),
        ],
      ),
    );
  }
}
