import 'package:flutter_test/flutter_test.dart';

import 'package:lowkey_maps/main.dart';

void main() {
  testWidgets('App renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const LowkeyMapsApp());
    expect(find.text('Lowkey Maps'), findsOneWidget);
  });
}
