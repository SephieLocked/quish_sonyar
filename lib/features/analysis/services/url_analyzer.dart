import '../models/security_finding.dart';

class UrlAnalyzer {
  List<SecurityFinding> analyze(Uri uri, {String? rawUrl}) {
    final findings = <SecurityFinding>[];

    _checkHttp(uri, findings);
    _checkIpAddress(uri, findings);
    _checkCredentials(uri, findings);
    _checkPunycode(uri, findings);
    _checkSubdomains(uri, findings);
    _checkKeywords(uri, findings);
    _checkUnusualPort(uri, findings);
    _checkEncodedPath(rawUrl ?? uri.toString(), findings);

    return findings;
  }

  void _checkHttp(Uri uri, List<SecurityFinding> findings) {
    if (uri.scheme.toLowerCase() == 'http') {
      findings.add(
        const SecurityFinding(
          code: 'http_connection',
          description:
              'This URL uses HTTP instead of HTTPS. '
              'The connection is not protected by HTTPS encryption.',
          severity: FindingSeverity.low,
        ),
      );
    }
  }

  void _checkIpAddress(Uri uri, List<SecurityFinding> findings) {
    final host = uri.host.replaceAll('[', '').replaceAll(']', '');

    try {
      Uri.parseIPv4Address(host);

      findings.add(
        const SecurityFinding(
          code: 'ipv4_address',
          description:
              'This URL uses an IPv4 address instead of a domain name.',
          severity: FindingSeverity.low,
        ),
      );
      return;
    } on FormatException {
      // Not IPv4.
    }

    try {
      Uri.parseIPv6Address(host);

      findings.add(
        const SecurityFinding(
          code: 'ipv6_address',
          description:
              'This URL uses an IPv6 address instead of a domain name.',
          severity: FindingSeverity.low,
        ),
      );
    } on FormatException {
      // Not IPv6.
    }
  }

  void _checkCredentials(Uri uri, List<SecurityFinding> findings) {
    if (uri.userInfo.isNotEmpty) {
      findings.add(
        const SecurityFinding(
          code: 'embedded_credentials',
          description:
              'This URL contains embedded user information. '
              'The actual destination is the hostname after the @ symbol.',
          severity: FindingSeverity.medium,
        ),
      );
    }
  }

  void _checkPunycode(Uri uri, List<SecurityFinding> findings) {
    final labels = uri.host.toLowerCase().split('.');

    if (labels.any((label) => label.startsWith('xn--'))) {
      findings.add(
        const SecurityFinding(
          code: 'punycode_hostname',
          description:
              'This domain uses Punycode encoding. '
              'International characters may resemble other letters.',
          severity: FindingSeverity.informational,
        ),
      );
    }
  }

  void _checkSubdomains(Uri uri, List<SecurityFinding> findings) {
    final host = uri.host;

    if (host.contains(':')) {
      return;
    }

    final labels = host.split('.');

    if (labels.length > 4) {
      findings.add(
        const SecurityFinding(
          code: 'excessive_subdomain',
          description:
              'This hostname contains many subdomain levels. '
              'Verify the actual registered domain.',
          severity: FindingSeverity.informational,
        ),
      );
    }
  }

  void _checkKeywords(Uri uri, List<SecurityFinding> findings) {
    const suspiciousKeywords = [
      'verify-account',
      'confirm-password',
      'reset-password',
      'secure-login',
      'account-suspended',
    ];

    final path = uri.path.toLowerCase();

    for (final keyword in suspiciousKeywords) {
      if (path.contains(keyword)) {
        findings.add(
          SecurityFinding(
            code: 'suspicious_keyword',
            description:
                'The URL path contains a potentially suspicious '
                'keyword: "$keyword".',
            severity: FindingSeverity.low,
          ),
        );
      }
    }
  }

  void _checkUnusualPort(Uri uri, List<SecurityFinding> findings) {
    if (!uri.hasPort) {
      return;
    }

    final standardPort =
        (uri.scheme == 'http' && uri.port == 80) ||
        (uri.scheme == 'https' && uri.port == 443);

    if (!standardPort) {
      findings.add(
        SecurityFinding(
          code: 'unusual_port',
          description: 'This URL specifies a non-standard port: ${uri.port}.',
          severity: FindingSeverity.informational,
        ),
      );
    }
  }

  void _checkEncodedPath(String rawUrl, List<SecurityFinding> findings) {
    if (RegExp(r'%[0-9a-fA-F]{2}').hasMatch(rawUrl)) {
      findings.add(
        const SecurityFinding(
          code: 'percent_encoding',
          description: 'This URL contains percent-encoded characters.',
          severity: FindingSeverity.informational,
        ),
      );
    }
  }
}
