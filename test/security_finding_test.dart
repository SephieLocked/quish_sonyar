import 'package:flutter_test/flutter_test.dart';
import 'package:quish_sonyar/features/analysis/models/security_finding.dart';

void main() {
  test('SecurityFinding stores its properties', () {
    const finding = SecurityFinding(
      code: 'http_connection',
      description: 'The URL uses HTTP.',
      severity: FindingSeverity.low,
    );

    expect(finding.code, 'http_connection');
    expect(finding.description, 'The URL uses HTTP.');
    expect(finding.severity, FindingSeverity.low);
  });
}
