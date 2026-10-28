
class UrlAnalyzer {
  /// Analyzes a URL without opening or visiting it.
  List<String> analyze(Uri uri) {
    final findings = <String>[];

    _checkHttp(uri, findings);
    _checkIpAddress(uri, findings);
    _checkCredentials(uri, findings);
    _checkPunycode(uri, findings);
    _checkSubdomains(uri, findings);
    _checkKeywords(uri, findings);

    return findings;
  }

  // Check whether the URL uses unencrypted HTTP.
  void _checkHttp(Uri uri, List<String> findings) {
    if (uri.scheme.toLowerCase() == 'http') {
      findings.add(
        'This URL uses HTTP instead of HTTPS. '
            'Information sent over this connection may not be encrypted.',
      );
    }
  }

  // Check whether the hostname is an IPv4 address.
  void _checkIpAddress(Uri uri, List<String> findings) {
    final host = uri.host;

    final ipv4Pattern = RegExp(
      r'^(?:\d{1,3}\.){3}\d{1,3}$',
    );

    if (ipv4Pattern.hasMatch(host)) {
      findings.add(
        'This URL uses an IP address instead of a domain name.',
      );
    }
  }

  // Check for embedded user information.
  void _checkCredentials(Uri uri, List<String> findings) {
    if (uri.userInfo.isNotEmpty) {
      findings.add(
        'This URL contains embedded user information. '
            'This can be used to disguise the actual destination.',
      );
    }
  }

  // Check for Punycode in the hostname.
  void _checkPunycode(Uri uri, List<String> findings) {
    if (uri.host.toLowerCase().contains('xn--')) {
      findings.add(
        'This domain contains Punycode, which may represent '
            'international characters or visually similar letters.',
      );
    }
  }

  // Check for unusually many hostname labels.
  void _checkSubdomains(Uri uri, List<String> findings) {
    final labels = uri.host.split('.');

    if (labels.length > 4) {
      findings.add(
        'This URL contains an unusually large number '
            'of subdomain levels.',
      );
    }
  }

  // Check for common phishing-related keywords.
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
}
