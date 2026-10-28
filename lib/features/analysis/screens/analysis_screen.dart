
import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/analysis_service.dart';
import '../widgets/risk_indicator.dart';

class AnalysisScreen extends StatefulWidget {
  final String qrContent;

  const AnalysisScreen({
    super.key,
    required this.qrContent,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final AnalysisService _analysisService = AnalysisService();

  late Future<AnalysisResult> _analysisFuture;

  @override
  void initState() {
    super.initState();

    // Run analysis once when the screen is created.
    _analysisFuture = _analysisService.analyze(
      widget.qrContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Security Analysis'),
        centerTitle: true,
      ),
      body: FutureBuilder<AnalysisResult>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState !=
              ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing QR content...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final result = snapshot.data;

          if (result == null) {
            return _buildErrorState();
          }

          return _buildResults(result);
        },
      ),
    );
  }

  Widget _buildResults(AnalysisResult result) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Risk classification.
          RiskIndicator(
            riskLevel: result.riskLevel,
          ),

          const SizedBox(height: 24),

          // Content type.
          Text(
            'Content Type',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(height: 8),

          Text(_getContentTypeLabel(result.contentType)),

          const SizedBox(height: 24),

          // Original QR content.
          Text(
            'Decoded QR Content',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              result.rawContent,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 24),

          // Findings.
          Text(
            'Analysis Findings',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(height: 12),

          ...result.findings.map(
                (finding) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.orange,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(finding),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Important disclaimer.
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Icon(Icons.security_outlined),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'This is a preliminary assessment '
                          'based on local URL checks. '
                          'It cannot guarantee that a '
                          'website is safe or malicious.',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Return to scanner.
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan Another QR'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            const Text(
              'Analysis could not be completed.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Return to Scanner'),
            ),
          ],
        ),
      ),
    );
  }

  String _getContentTypeLabel(ContentType type) {
    switch (type) {
      case ContentType.url:
        return 'Website URL';

      case ContentType.text:
        return 'Text or Unsupported URI';

      case ContentType.other:
        return 'Other / Empty Content';
    }
  }
}
