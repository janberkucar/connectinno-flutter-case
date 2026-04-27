import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smokes: MaterialApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('connectinno_notes')),
        ),
      ),
    );
    expect(find.text('connectinno_notes'), findsOneWidget);
  });
}
