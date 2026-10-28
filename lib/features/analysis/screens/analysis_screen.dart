import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../models/security_finding.dart';
import '../services/analysis_service.dart';
import '../widgets/risk_indicator.dart';

class AnalysisScreen extends StatefulWidget {
  final String qrContent;

  const AnalysisScreen({super.key, required this.qrContent});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final AnalysisService _analysisService = AnalysisService();

  late Future<AnalysisResult> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() {
    _analysisFuture = _analysisService.analyze(widget.qrContent);
  }

  @override
  void didUpdateWidget(covariant AnalysisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.qrContent != widget.qrContent) {
      _startAnalysis();
    }
  }

  void _retryAnalysis() {
    setState(() {
      _startAnalysis();
    });
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
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildLoadingState();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState();
          }

          return _buildResults(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
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

  Widget _buildResults(AnalysisResult result) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Overall risk classification.
          RiskIndicator(riskLevel: result.riskLevel),

          const SizedBox(height: 24),

          // Content classification.
          Text('Content Type', style: theme.textTheme.titleMedium),

          const SizedBox(height: 8),

          Text(_getContentTypeLabel(result.contentType)),

          const SizedBox(height: 24),

          // Original decoded QR content.
          Text('Decoded QR Content', style: theme.textTheme.titleMedium),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              result.rawContent,
              style: theme.textTheme.bodyMedium,
            ),
          ),

          const SizedBox(height: 24),

          // Security findings.
          Text('Analysis Findings', style: theme.textTheme.titleMedium),

          const SizedBox(height: 12),

          if (result.findings.isEmpty)
            _buildEmptyFindings()
          else
            ...result.findings.map(_buildFindingCard),

          const SizedBox(height: 20),

          // Security disclaimer.
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.security_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is a preliminary assessment '
                      'based on local URL checks. '
                      'No detected warnings does not '
                      'mean a website is safe. '
                      'Always verify unfamiliar links.',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan Another QR'),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingCard(SecurityFinding finding) {
    final color = _severityColor(finding.severity);
    final icon = _severityIcon(finding.severity);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _severityLabel(finding.severity),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(finding.description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFindings() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No suspicious URL characteristics were '
                'detected by the current local checks. '
                'The destination has not been verified '
                'as safe.',
              ),
            ),
          ],
        ),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),

            const SizedBox(height: 16),

            const Text(
              'Analysis could not be completed.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _retryAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to Scanner'),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(FindingSeverity severity) {
    switch (severity) {
      case FindingSeverity.informational:
        return Colors.blue;

      case FindingSeverity.low:
        return Colors.green;

      case FindingSeverity.medium:
        return Colors.orange;

      case FindingSeverity.high:
        return Colors.red;
    }
  }

  IconData _severityIcon(FindingSeverity severity) {
    switch (severity) {
      case FindingSeverity.informational:
        return Icons.info_outline;

      case FindingSeverity.low:
        return Icons.visibility_outlined;

      case FindingSeverity.medium:
        return Icons.warning_amber_outlined;

      case FindingSeverity.high:
        return Icons.dangerous_outlined;
    }
  }

  String _severityLabel(FindingSeverity severity) {
    switch (severity) {
      case FindingSeverity.informational:
        return 'INFORMATIONAL';

      case FindingSeverity.low:
        return 'LOW SEVERITY';

      case FindingSeverity.medium:
        return 'MEDIUM SEVERITY';

      case FindingSeverity.high:
        return 'HIGH SEVERITY';
    }
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
