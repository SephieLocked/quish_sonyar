
import 'package:flutter_test/flutter_test.dart';
import 'package:quish_sonyar/features/analysis/models/analysis_result.dart';
import 'package:quish_sonyar/features/analysis/services/analysis_service.dart';

void main() {
  late AnalysisService service;

  setUp(() {
    service = AnalysisService();
  });

  group('AnalysisService', () {
    test('Recognizes a standard HTTPS URL', () async {
      final result = await service.analyze(
        'https://example.com',
      );

      expect(result.contentType, ContentType.url);
      expect(result.riskLevel, RiskLevel.unknown);
      expect(result.isComplete, isTrue);
    });

    test('Detects an HTTP URL', () async {
      final result = await service.analyze(
        'http://example.com',
      );

      expect(result.contentType, ContentType.url);
      expect(result.riskLevel, RiskLevel.low);
      expect(result.findings, isNotEmpty);
    });

    test('Classifies multiple findings', () async {
      final result = await service.analyze(
        'http://192.168.1.100/verify-account',
      );

      expect(result.contentType, ContentType.url);
      expect(result.riskLevel, RiskLevel.high);
      expect(result.findings.length, 3);
    });

    test('Recognizes ordinary text', () async {
      final result = await service.analyze(
        'Hello from Quish Sonyar!',
      );

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
      final result = await service.analyze(
        'https://example.com/login',
      );

      expect(result.isComplete, isTrue);
      expect(result.rawContent,
          'https://example.com/login');
    });

    test('Recognizes URLs without schemes', () async {
      final result = await service.analyze(
        'example.com/login',
      );

      expect(result.contentType, ContentType.url);
      expect(result.riskLevel, RiskLevel.unknown);
      expect(result.isComplete, isTrue);
    });
  });
}
