import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../analysis/screens/analysis_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;

    String? content;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        content = value;
        break;
      }
    }

    if (content == null) return;

    _isProcessing = true;

    try {
      await _controller.stop();

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AnalysisScreen(qrContent: content!),
        ),
      );
    } finally {
      if (mounted) {
        try {
          await _controller.start();
        } catch (error) {
          debugPrint('Could not restart scanner: $error');
        }
      }
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quish Sonyar'), centerTitle: true),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetection),

          const Center(
            child: Icon(Icons.crop_free, size: 250, color: Colors.pinkAccent),
          ),

          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Point your camera at a QR code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 6, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
