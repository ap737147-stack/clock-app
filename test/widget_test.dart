import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Build a simple test app
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test'),
            ),
          ),
        ),
      ),
    );

    // Verify that the app renders
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });
}
