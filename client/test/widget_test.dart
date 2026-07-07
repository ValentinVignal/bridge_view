// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bridge_view_client/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders connection page', (WidgetTester tester) async {
    await tester.pumpWidget(const BridgeView());
    expect(find.text('Bridge View'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
  });
}
