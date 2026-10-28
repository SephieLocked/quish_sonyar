
import 'package:flutter_test/flutter_test.dart';
import 'package:quish_sonyar/core/utils/url_utils.dart';

void main() {
  group('UrlUtils.normalize', () {
    test('Adds HTTPS to a domain', () {
      final uri = UrlUtils.normalize('example.com');

      expect(uri.toString(), 'https://example.com');
    });

    test('Adds HTTPS to a domain with a path', () {
      final uri = UrlUtils.normalize(
        'www.example.com/login',
      );

      expect(
        uri.toString(),
        'https://www.example.com/login',
      );
    });

    test('Preserves explicit HTTP', () {
      final uri = UrlUtils.normalize(
        'http://example.com',
      );

      expect(uri?.scheme, 'http');
    });

    test('Recognizes uppercase HTTPS', () {
      final uri = UrlUtils.normalize(
        'HTTPS://example.com',
      );

      expect(uri?.scheme, 'https');
    });

    test('Recognizes IPv4 addresses', () {
      final uri = UrlUtils.normalize(
        '192.168.1.100/login',
      );

      expect(uri?.host, '192.168.1.100');
    });

    test('Rejects ordinary text', () {
      final uri = UrlUtils.normalize(
        'Hello Sister!',
      );

      expect(uri, isNull);
    });

    test('Rejects JavaScript scheme', () {
      final uri = UrlUtils.normalize(
        'javascript:alert(1)',
      );

      expect(uri, isNull);
    });

    test('Rejects mailto scheme', () {
      final uri = UrlUtils.normalize(
        'mailto:test@example.com',
      );

      expect(uri, isNull);
    });

    test('Rejects empty content', () {
      final uri = UrlUtils.normalize('');

      expect(uri, isNull);
    });

    test('Preserves explicit URL userinfo', () {
      final uri = UrlUtils.normalize(
        'https://trusted.example@other.example/login',
      );

      expect(uri?.host, 'other.example');
      expect(uri?.userInfo, 'trusted.example');
    });
  });
}
