import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safewear/main.dart';

void main() {
  testWidgets('SafeWear app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SafeWearApp()));
    expect(find.byType(MaterialApp), findsNothing);
  });
}
