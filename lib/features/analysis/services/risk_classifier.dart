import '../models/analysis_result.dart';
import '../models/security_finding.dart';

class RiskClassifier {
  static RiskLevel classify(List<SecurityFinding> findings) {
    if (findings.any((finding) => finding.severity == FindingSeverity.high)) {
      return RiskLevel.high;
    }

    if (findings.any((finding) => finding.severity == FindingSeverity.medium)) {
      return RiskLevel.medium;
    }

    if (findings.any((finding) => finding.severity == FindingSeverity.low)) {
      return RiskLevel.low;
    }

    return RiskLevel.unknown;
  }
}
