
enum RiskLevel {
  low,
  medium,
  high,
  unknown,
}

enum ContentType {
  url,
  text,
  other,
}

class AnalysisResult {
  // Original content extracted from the QR code.
  final String rawContent;

  // Type of content found in the QR code.
  final ContentType contentType;

  // Preliminary security assessment.
  final RiskLevel riskLevel;

  // Reasons explaining the assessment.
  final List<String> findings;

  // Whether analysis has finished.
  final bool isComplete;

  const AnalysisResult({
    required this.rawContent,
    required this.contentType,
    this.riskLevel = RiskLevel.unknown,
    this.findings = const [],
    this.isComplete = false,
  });
}
