import 'package:flutter/material.dart';

/// A symbol stored as text, for symbols with one drawing each (DB), in a box
/// 120 wide and 100 high: `M x y` moves, `L x y` draws a line, `Q` and `C`
/// draw curves (as in SVG), `O x y r` draws a circle and `D x y r` a filled
/// dot.
class SymbolPath {
  const SymbolPath._(this.outline, this.dots);

  factory SymbolPath.parse(String text) {
    final path = Path();
    final dots = <Rect>[];
    final tokens = RegExp(r'[A-Z]|-?\d+(\.\d+)?')
        .allMatches(text)
        .map((m) => m[0]!)
        .toList();
    var i = 0;
    double number() => double.parse(tokens[i++]);
    while (i < tokens.length) {
      switch (tokens[i++]) {
        case 'M':
          path.moveTo(number(), number());
        case 'L':
          path.lineTo(number(), number());
        case 'Q':
          path.quadraticBezierTo(number(), number(), number(), number());
        case 'C':
          path.cubicTo(
            number(),
            number(),
            number(),
            number(),
            number(),
            number(),
          );
        case 'O':
          final (x, y, r) = (number(), number(), number());
          path.addOval(Rect.fromCircle(center: Offset(x, y), radius: r));
        case 'D':
          final (x, y, r) = (number(), number(), number());
          dots.add(Rect.fromCircle(center: Offset(x, y), radius: r));
        case final command:
          throw FormatException('Unknown symbol command: $command', text);
      }
    }
    return SymbolPath._(path, dots);
  }

  static const aspect = 1.2;

  final Path outline;
  final List<Rect> dots;
}

/// Draws a [SymbolPath] given as text, [size] high, read out as [label].
class PathSymbolView extends StatelessWidget {
  const PathSymbolView(
    this.path, {
    super.key,
    required this.label,
    this.size = 24,
    this.color,
  });

  final String path;
  final String label;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: CustomPaint(
      size: Size(size * SymbolPath.aspect, size),
      painter: PathSymbolPainter(
        SymbolPath.parse(path),
        path,
        color ?? IconTheme.of(context).color!,
      ),
    ),
  );
}

/// Paints a [SymbolPath].
class PathSymbolPainter extends CustomPainter {
  const PathSymbolPainter(this.symbol, this.source, this.color);

  final SymbolPath symbol;
  final String source;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.height / 100);
    canvas.drawPath(
      symbol.outline,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final fill = Paint()..color = color;
    for (final dot in symbol.dots) {
      canvas.drawOval(dot, fill);
    }
  }

  @override
  bool shouldRepaint(PathSymbolPainter oldDelegate) =>
      oldDelegate.source != source || oldDelegate.color != color;
}
