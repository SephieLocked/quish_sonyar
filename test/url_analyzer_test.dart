import 'package:flutter_test/flutter_test.dart';
import 'package:quish_sonyar/features/analysis/services/url_analyzer.dart';

void main() {
  group('UrlAnalyzer', () {
    final analyzer = UrlAnalyzer();

    test('Detects HTTP URLs', () {
      final uri = Uri.parse('http://example.com');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((finding) => finding.description.contains('HTTP')),
        isTrue,
      );
    });

    test('Detects IPv4 hostnames', () {
      final uri = Uri.parse('https://192.168.1.100');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((finding) => finding.description.contains('IPv4 address')),
        isTrue,
      );
    });

    test('Detects embedded credentials', () {
      final uri = Uri.parse('https://example.com@other.example/login');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((finding) => finding.description.contains('embedded')),
        isTrue,
      );
    });

    test('Detects suspicious keywords', () {
      final uri = Uri.parse('https://example.com/verify-account');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any(
          (finding) => finding.description.contains('verify-account'),
        ),
        isTrue,
      );
    });

    test('Does not flag ordinary HTTPS URL', () {
      final uri = Uri.parse('https://example.com');

      final findings = analyzer.analyze(uri);

      expect(findings, isEmpty);
    });

    test('Detects IPv6 hostnames', () {
      final uri = Uri.parse('https://[2001:db8::1]/login');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((f) => f.description.contains('IPv6 address')),
        isTrue,
      );
    });

    test('Detects unusual ports', () {
      final uri = Uri.parse('https://example.com:8443/login');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((f) => f.description.contains('non-standard port')),
        isTrue,
      );
    });

    test('Does not flag standard HTTPS port', () {
      final uri = Uri.parse('https://example.com:443');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((f) => f.description.contains('non-standard port')),
        isFalse,
      );
    });

    test('Detects percent-encoded paths', () {
      const rawUrl = 'https://example.com/%76erify-account';

      final findings = analyzer.analyze(Uri.parse(rawUrl), rawUrl: rawUrl);

      expect(
        findings.any((f) => f.description.contains('percent-encoded')),
        isTrue,
      );
    });

    test('Detects keywords in decoded paths', () {
      final uri = Uri.parse('https://example.com/%76erify-account');

      final findings = analyzer.analyze(uri);

      expect(
        findings.any((f) => f.description.contains('verify-account')),
        isTrue,
      );
    });

    test('Does not flag ordinary HTTPS URLs', () {
      final uri = Uri.parse('https://example.com/about');

      final findings = analyzer.analyze(uri);

      expect(findings, isEmpty);
    });
  });
}
