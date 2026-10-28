import 'package:flutter/material.dart';

import '../models/analysis_result.dart';

class RiskIndicator extends StatelessWidget {
  final RiskLevel riskLevel;

  const RiskIndicator({
    super.key,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();
    final label = _getLabel();
    final description = _getDescription();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.40),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 64,
          ),

          const SizedBox(height: 16),

          Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green.shade700;

      case RiskLevel.medium:
        return Colors.orange.shade800;

      case RiskLevel.high:
        return Colors.red.shade700;

      case RiskLevel.unknown:
        return Colors.grey.shade700;
    }
  }

  IconData _getIcon() {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.verified_user_outlined;

      case RiskLevel.medium:
        return Icons.warning_amber_rounded;

      case RiskLevel.high:
        return Icons.gpp_bad_outlined;

      case RiskLevel.unknown:
        return Icons.help_outline_rounded;
    }
  }

  String _getLabel() {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';

      case RiskLevel.medium:
        return 'Medium Risk';

      case RiskLevel.high:
        return 'High Risk';

      case RiskLevel.unknown:
        return 'Unknown Risk';
    }
  }

  String _getDescription() {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'One potential risk indicator was detected. '
            'This does not establish whether the link is safe.';

      case RiskLevel.medium:
        return 'Multiple suspicious characteristics were detected. '
            'Exercise caution before visiting this link.';

      case RiskLevel.high:
        return 'Several suspicious characteristics were detected. '
            'Avoid opening this link unless you can verify its destination.';

      case RiskLevel.unknown:
        return 'The current analysis could not establish '
            'whether this content is safe.';
    }
  }
}
