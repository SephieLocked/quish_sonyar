import 'package:flutter_test/flutter_test.dart';
import 'package:quish_sonyar/features/analysis/models/analysis_result.dart';
import 'package:quish_sonyar/features/analysis/models/security_finding.dart';
import 'package:quish_sonyar/features/analysis/services/risk_classifier.dart';

void main() {
  SecurityFinding finding(FindingSeverity severity) {
    return SecurityFinding(
      code: severity.name,
      description: 'Test finding',
      severity: severity,
    );
  }

  group('RiskClassifier', () {
    test('No findings returns Unknown', () {
      expect(RiskClassifier.classify([]), RiskLevel.unknown);
    });

    test('Informational findings return Unknown', () {
      expect(
        RiskClassifier.classify([
          finding(FindingSeverity.informational),
          finding(FindingSeverity.informational),
          finding(FindingSeverity.informational),
        ]),
        RiskLevel.unknown,
      );
    });

    test('Low severity returns Low', () {
      expect(
        RiskClassifier.classify([finding(FindingSeverity.low)]),
        RiskLevel.low,
      );
    });

    test('Medium overrides Low', () {
      expect(
        RiskClassifier.classify([
          finding(FindingSeverity.low),
          finding(FindingSeverity.medium),
        ]),
        RiskLevel.medium,
      );
    });

    test('High overrides all other severities', () {
      expect(
        RiskClassifier.classify([
          finding(FindingSeverity.informational),
          finding(FindingSeverity.low),
          finding(FindingSeverity.medium),
          finding(FindingSeverity.high),
        ]),
        RiskLevel.high,
      );
    });
  });
}
