import 'package:flutter/material.dart';
import '../features/scanner/screens/scanner_screen.dart';

class QuishSonyarApp extends StatelessWidget {
  const QuishSonyarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quish Sonyar',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
      ),

      home: const ScannerScreen(),
    );
  }
}
