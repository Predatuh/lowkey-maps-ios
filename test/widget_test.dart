import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lowkey_maps/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const LowkeyMapsApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
