import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a basic DailyLingo smoke screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('DailyLingo'))),
      ),
    );

    expect(find.text('DailyLingo'), findsOneWidget);
  });
}
