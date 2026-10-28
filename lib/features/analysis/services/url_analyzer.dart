
class UrlAnalyzer {
  List<String> analyze(
      Uri uri, {
        String? rawUrl,
      }) {
    final findings = <String>[];

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

  void _checkHttp(Uri uri, List<String> findings) {
    if (uri.scheme.toLowerCase() == 'http') {
      findings.add(
        'This URL uses HTTP instead of HTTPS. '
            'The connection is not protected by HTTPS encryption.',
      );
    }
  }


  void _checkIpAddress(Uri uri, List<String> findings) {
    final host = uri.host;

    try {
      Uri.parseIPv4Address(host);

      findings.add(
        'This URL uses an IPv4 address instead of a domain name.',
      );
      return;
    } on FormatException {
      // Not IPv4.
    }

    try {
      Uri.parseIPv6Address(
        host.replaceAll('[', '').replaceAll(']', ''),
      );

      findings.add(
        'This URL uses an IPv6 address instead of a domain name.',
      );
    } on FormatException {
      // Not IPv6.
    }
  }


  void _checkCredentials(Uri uri, List<String> findings) {
    if (uri.userInfo.isNotEmpty) {
      findings.add(
        'This URL contains embedded user information. '
            'The actual destination is the hostname after the @ symbol.',
      );
    }
  }

  void _checkPunycode(Uri uri, List<String> findings) {
    final labels = uri.host.toLowerCase().split('.');

    if (labels.any((label) => label.startsWith('xn--'))) {
      findings.add(
        'This domain uses Punycode encoding. '
            'International characters may resemble other letters.',
      );
    }
  }

  void _checkSubdomains(Uri uri, List<String> findings) {
    final host = uri.host;

    if (host.contains(':')) {
      return;
    }

    final labels = host.split('.');

    if (labels.length > 4) {
      findings.add(
        'This hostname contains many subdomain levels. '
            'Verify the actual registered domain.',
      );
    }
  }

  void _checkKeywords(Uri uri, List<String> findings) {
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
          'The URL path contains a potentially suspicious '
              'keyword: "$keyword".',
        );
      }
    }
  }

  void _checkUnusualPort(Uri uri, List<String> findings) {
    if (!uri.hasPort) {
      return;
    }

    final standardPort =
        (uri.scheme == 'http' && uri.port == 80) ||
            (uri.scheme == 'https' && uri.port == 443);

    if (!standardPort) {
      findings.add(
        'This URL specifies a non-standard port: ${uri.port}.',
      );
    }
  }

  void _checkEncodedPath(
      String rawUrl,
      List<String> findings,
      ) {
    if (RegExp(r'%[0-9a-fA-F]{2}').hasMatch(rawUrl)) {
      findings.add(
        'This URL contains percent-encoded characters.',
      );
    }
  }
}
