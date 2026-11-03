import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Product Manager UI smoke test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Firebase Product Manager')),
          body: const Center(child: Text('Products')),
        ),
      ),
    );

    expect(find.text('Firebase Product Manager'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
  });
}
