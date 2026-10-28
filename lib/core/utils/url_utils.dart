class UrlUtils {
  /// Converts recognizable web addresses into parsed URIs.
  ///
  /// Returns null if the content is not a supported web URL.
  /// This method does not open or contact any website.
  static Uri? normalize(String input) {
    final content = input.trim();

    if (content.isEmpty) {
      return null;
    }

    // Reject whitespace and control characters within URLs.
    if (RegExp(r'[\s\x00-\x1F\x7F]').hasMatch(content)) {
      return null;
    }

    final parsed = Uri.tryParse(content);

    if (parsed == null) {
      return null;
    }

    // Preserve explicitly supplied HTTP/HTTPS schemes.
    if (parsed.hasScheme) {
      if (parsed.scheme != 'http' && parsed.scheme != 'https') {
        return null;
      }

      return _isValidWebUri(parsed) ? parsed : null;
    }

    // Do not accept protocol-relative URLs in this version.
    if (content.startsWith('//')) {
      return null;
    }

    // Reject inputs with URL userinfo syntax but no scheme.
    // We'll require explicit schemes for these unusual URLs.
    final authority = content.split(RegExp(r'[/?#]')).first;

    if (authority.contains('@')) {
      return null;
    }

    // Assume HTTPS for recognizable domain or IPv4 URLs.
    final normalized = Uri.tryParse('https://$content');

    if (normalized == null || !_isValidWebUri(normalized)) {
      return null;
    }

    return normalized;
  }

  static bool _isValidWebUri(Uri uri) {
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }

    if (uri.host.isEmpty) {
      return false;
    }

    // Reject explicit userinfo only when no scheme was supplied.
    // For explicit URLs, leave userinfo for the URL analyzer.
    final host = uri.host;

    if (host == 'localhost') {
      return true;
    }

    try {
      Uri.parseIPv4Address(host);
      return true;
    } on FormatException {
      // Not an IPv4 address; continue checking the hostname.
    }

    if (host.contains(':')) {
      // IPv6 host; Uri has already parsed the authority.
      return true;
    }

    // Require a plausible dotted hostname.
    final labels = host.split('.');

    if (labels.length < 2) {
      return false;
    }

    final labelPattern = RegExp(r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$');

    for (final label in labels) {
      if (label.isEmpty || label.length > 63 || !labelPattern.hasMatch(label)) {
        return false;
      }
    }

    return host.length <= 253;
  }
}
