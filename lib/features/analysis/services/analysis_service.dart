import '../models/analysis_result.dart';
import '../models/security_finding.dart';
import 'url_analyzer.dart';
import '../../../core/utils/url_utils.dart';
import 'risk_classifier.dart';

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
        findings: <SecurityFinding>[],
        isComplete: true,
      );
    }

    // Attempt to parse the content as a URI.
    final uri = UrlUtils.normalize(content);

    // Non-URL content.
    if (uri == null) {
      return AnalysisResult(
        rawContent: rawContent,
        contentType: ContentType.text,
        riskLevel: RiskLevel.unknown,
        findings: <SecurityFinding>[],
        isComplete: true,
      );
    }

    // Analyze the normalized URL.
    final securityFindings = _urlAnalyzer.analyze(uri, rawUrl: content);

    // Determine preliminary risk classification.
    final riskLevel = RiskClassifier.classify(securityFindings);

    return AnalysisResult(
      rawContent: rawContent,
      contentType: ContentType.url,
      riskLevel: riskLevel,
      findings: securityFindings,
      isComplete: true,
    );
  }
}
