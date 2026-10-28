
import 'package:flutter_test/flutter_test.dart';
import 'package:quish_sonyar/features/analysis/services/url_analyzer.dart';

void main() {
  group('UrlAnalyzer', () {
    final analyzer = UrlAnalyzer();

    test('Detects HTTP URLs', () {
      final uri = Uri.parse('http://example.com');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((finding) => finding.contains('HTTP')),
        isTrue,
      );
    });

    test('Detects IPv4 hostnames', () {
      final uri = Uri.parse('https://192.168.1.100');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((finding) => finding.contains('IP address')),
        isTrue,
      );
    });

    test('Detects embedded credentials', () {
      final uri = Uri.parse(
        'https://example.com@other.example/login',
      );

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((finding) => finding.contains('embedded')),
        isTrue,
      );
    });

    test('Detects suspicious keywords', () {
      final uri = Uri.parse(
        'https://example.com/verify-account',
      );

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((finding) => finding.contains('verify-account')),
        isTrue,
      );
    });

    test('Does not flag ordinary HTTPS URL', () {
      final uri = Uri.parse('https://example.com');

      final findings = analyzer.analyze(uri);

      expect(findings, isEmpty);
    });
  });
}
