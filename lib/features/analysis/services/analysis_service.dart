import '../models/analysis_result.dart';
import 'url_analyzer.dart';
import '../../../core/utils/url_utils.dart';

class AnalysisService {
  final UrlAnalyzer _urlAnalyzer;

  AnalysisService({UrlAnalyzer? urlAnalyzer})
      : _urlAnalyzer = urlAnalyzer ?? UrlAnalyzer();

  /// Analyzes the raw content extracted from a QR code.
  Future<AnalysisResult> analyze(String rawContent) async {
    final content = rawContent.trim();

    // Empty QR content.
    if (content.isEmpty) {
      return AnalysisResult(
        rawContent: rawContent,
        contentType: ContentType.other,
        riskLevel: RiskLevel.unknown,
        findings: ['The QR code contains no readable content.'],
        isComplete: true,
      );
    }

    // Attempt to parse the content as a URI.
    final uri = UrlUtils.normalize(content);

    if (uri == null) {
      return AnalysisResult(
        rawContent: rawContent,
        contentType: ContentType.text,
        riskLevel: RiskLevel.unknown,
        findings: [
          'The QR content is not a recognized HTTP or HTTPS URL.',
          'No web URL security analysis was performed.',
        ],
        isComplete: true,
      );
    }

    final findings = _urlAnalyzer.analyze(uri);

    // Determine a preliminary risk classification.
    final riskLevel = _classifyRisk(findings);

    return AnalysisResult(
      rawContent: rawContent,
      contentType: ContentType.url,
      riskLevel: riskLevel,
      findings: findings.isEmpty
          ? [
        'No suspicious patterns were detected '
            'by the current local checks.',
        'This does not guarantee the website is safe.',
      ]
          : findings,
      isComplete: true,
    );
  }

  /// Temporary heuristic-based risk classification.
  RiskLevel _classifyRisk(List<String> findings) {
    if (findings.isEmpty) {
      return RiskLevel.unknown;
    }

    if (findings.length >= 3) {
      return RiskLevel.high;
    }

    if (findings.length == 2) {
      return RiskLevel.medium;
    }

    return RiskLevel.low;
  }
}
