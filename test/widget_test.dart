import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dilos/app.dart';

void main() {
  testWidgets('DilosApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DilosApp()),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
