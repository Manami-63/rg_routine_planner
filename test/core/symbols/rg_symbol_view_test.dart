import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/symbols/rg_symbol.dart';
import 'package:rg_routine_planner/core/symbols/rg_symbol_view.dart';

void main() {
  /// The pixels of [symbol], so tests can see what was drawn.
  Future<Uint8List> pixels(RgSymbol symbol) async {
    final size = Size(100 * symbol.aspect, 100);
    final recorder = ui.PictureRecorder();
    RgSymbolPainter(symbol, Colors.black).paint(Canvas(recorder), size);
    final image = await recorder.endRecording().toImage(
      size.width.ceil(),
      size.height.ceil(),
    );
    final bytes = await image.toByteData();
    return bytes!.buffer.asUint8List();
  }

  test('every symbol has a description and a reference', () {
    for (final symbol in RgSymbol.values) {
      expect(symbol.description, isNotEmpty);
      expect(symbol.reference, startsWith('#'));
    }
  });

  test('every symbol draws something inside its box', () async {
    for (final symbol in RgSymbol.values) {
      final width = (100 * symbol.aspect).ceil();
      final image = await pixels(symbol);
      final drawn = [
        for (var i = 3; i < image.length; i += 4)
          if (image[i] > 128) i ~/ 4,
      ];
      expect(drawn, isNotEmpty, reason: symbol.name);
      // Nothing is cut off by the edges of the box.
      final edge = drawn.where((p) => p % width == 0 || p % width == width - 1);
      expect(edge, isEmpty, reason: '${symbol.name} touches a side');
    }
  });

  test('no two symbols look the same', () async {
    final seen = <String, RgSymbol>{};
    for (final symbol in RgSymbol.values) {
      final key = (await pixels(symbol)).join(',');
      expect(seen[key], isNull, reason: symbol.name);
      seen[key] = symbol;
    }
  });

  testWidgets('sizes by the symbol and reads its description', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: RgSymbolView(RgSymbol.largeRoll, size: 20)),
      ),
    );
    expect(tester.getSize(find.byType(CustomPaint).last), const Size(34, 20));
    expect(find.bySemanticsLabel('Large roll'), findsOneWidget);
  });
}
