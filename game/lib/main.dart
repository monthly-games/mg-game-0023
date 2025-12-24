import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/game_state.dart';
import 'screens/colony_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameState())],
      child: const ColonyApp(),
    ),
  );
}

class ColonyApp extends StatelessWidget {
  const ColonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colony Frontier',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        useMaterial3: true,
      ),
      home: const ColonyScreen(),
    );
  }
}
