import 'package:flutter/material.dart';
import 'package:connect_game/models/point.dart';
import 'package:connect_game/custom_painter.dart';
import 'package:connect_game/screens/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ConnectGamePage(),
    );
  }
}
