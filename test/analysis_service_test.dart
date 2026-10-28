import 'package:flutter_test/flutter_test.dart';
import 'package:quish_sonyar/features/analysis/models/analysis_result.dart';
import 'package:quish_sonyar/features/analysis/services/analysis_service.dart';
import 'package:quish_sonyar/features/analysis/models/security_finding.dart';

void main() {
  late AnalysisService service;

  setUp(() {
    service = AnalysisService();
  });

  group('AnalysisService', () {
    test('Recognizes a standard HTTPS URL', () async {
      final result = await service.analyze('https://example.com');

      expect(result.contentType, ContentType.url);
      expect(result.riskLevel, RiskLevel.unknown);
      expect(result.isComplete, isTrue);
    });

    test('Detects an HTTP URL with structured findings', () async {
      final result = await service.analyze('http://example.com');

      expect(result.contentType, ContentType.url);
      expect(result.riskLevel, RiskLevel.low);
      expect(result.findings, isNotEmpty);

      final finding = result.findings.firstWhere(
        (finding) => finding.code == 'http_connection',
      );

      expect(finding.severity, FindingSeverity.low);
      expect(finding.description, contains('HTTP'));
    });

    test('Ordinary HTTPS URL has no security findings', () async {
      final result = await service.analyze('https://example.com');

      expect(result.riskLevel, RiskLevel.unknown);
      expect(result.findings, isEmpty);
    });

    test('Non-URL content has no URL findings', () async {
      final result = await service.analyze('Hello from Quish Sonyar!');

      expect(result.contentType, ContentType.text);
      expect(result.findings, isEmpty);
    });

    test('Multiple low-severity findings remain low risk', () async {
      final result = await service.analyze(
        'http://192.168.1.100/verify-account',
      );

      expect(result.contentType, ContentType.url);
      expect(result.riskLevel, RiskLevel.low);
      expect(result.findings.length, 3);
    });

    test('Embedded credentials produce medium risk', () async {
      final result = await service.analyze('https://user:password@example.com');

      expect(result.riskLevel, RiskLevel.medium);
    });

    test('Recognizes ordinary text', () async {
      final result = await service.analyze('Hello from Quish Sonyar!');

      expect(result.contentType, ContentType.text);
      expect(result.riskLevel, RiskLevel.unknown);
      expect(result.isComplete, isTrue);
    });

    test('Handles empty QR content', () async {
      final result = await service.analyze('');

      expect(result.contentType, ContentType.other);
      expect(result.riskLevel, RiskLevel.unknown);
      expect(result.isComplete, isTrue);
    });

    test('Does not automatically open URLs', () async {
      final result = await service.analyze('https://example.com/login');

      expect(result.isComplete, isTrue);
      expect(result.rawContent, 'https://example.com/login');
    });

    test('Recognizes URLs without schemes', () async {
      final result = await service.analyze('example.com/login');

      expect(result.contentType, ContentType.url);
      expect(result.riskLevel, RiskLevel.unknown);
      expect(result.isComplete, isTrue);
    });
  });
}
