import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quish_sonyar/features/analysis/models/analysis_result.dart';
import 'package:quish_sonyar/features/analysis/widgets/risk_indicator.dart';

void main() {
  Future<void> pumpIndicator(
      WidgetTester tester,
      RiskLevel level,
      ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RiskIndicator(
            riskLevel: level,
          ),
        ),
      ),
    );
  }

  group('RiskIndicator Widget Tests', () {
    testWidgets('Displays Low Risk', (tester) async {
      await pumpIndicator(tester, RiskLevel.low);

      expect(find.text('Low Risk'), findsOneWidget);
      expect(
        find.byIcon(Icons.verified_user_outlined),
        findsOneWidget,
      );
    });

    testWidgets('Displays Medium Risk', (tester) async {
      await pumpIndicator(tester, RiskLevel.medium);

      expect(find.text('Medium Risk'), findsOneWidget);
      expect(
        find.byIcon(Icons.warning_amber_rounded),
        findsOneWidget,
      );
    });

    testWidgets('Displays High Risk', (tester) async {
      await pumpIndicator(tester, RiskLevel.high);

      expect(find.text('High Risk'), findsOneWidget);
      expect(
        find.byIcon(Icons.gpp_bad_outlined),
        findsOneWidget,
      );
    });

    testWidgets('Displays Unknown Risk', (tester) async {
      await pumpIndicator(tester, RiskLevel.unknown);

      expect(find.text('Unknown Risk'), findsOneWidget);
      expect(
        find.byIcon(Icons.help_outline_rounded),
        findsOneWidget,
      );
    });
  });
}
