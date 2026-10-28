enum FindingSeverity { informational, low, medium, high }

class SecurityFinding {
  final String code;
  final String description;
  final FindingSeverity severity;

  const SecurityFinding({
    required this.code,
    required this.description,
    required this.severity,
  });
}
