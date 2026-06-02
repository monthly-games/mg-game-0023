import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('Colony Frontier app launches', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Colony Frontier'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
  });
}
