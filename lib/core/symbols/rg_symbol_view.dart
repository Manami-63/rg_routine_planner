import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'rg_symbol.dart';

/// Draws an [RgSymbol] [size] high, in [color] (default: the icon colour).
class RgSymbolView extends StatelessWidget {
  const RgSymbolView(this.symbol, {super.key, this.size = 24, this.color});

  final RgSymbol symbol;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Semantics(
    label: symbol.description,
    child: CustomPaint(
      size: Size(size * symbol.aspect, size),
      painter: RgSymbolPainter(symbol, color ?? IconTheme.of(context).color!),
    ),
  );
}

/// Paints a symbol. Every drawing uses a box 100 units high.
class RgSymbolPainter extends CustomPainter {
  const RgSymbolPainter(this.symbol, this.color);

  final RgSymbol symbol;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.height / 100);
    final width = 100 * symbol.aspect;
    canvas.drawPath(
      _outline(width),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final dots = _dots(width);
    if (dots.isNotEmpty) {
      final fill = Paint()..color = color;
      for (final dot in dots) {
        canvas.drawOval(dot, fill);
      }
    }
  }

  Path _outline(double w) => switch (symbol) {
    RgSymbol.largeRoll => _loops(w, 45),
    RgSymbol.rollOnFloor => _loops(w, 38)..addPath(_floor(w, 90), Offset.zero),
    RgSymbol.handling => _circle(
      w / 2 - 22,
      50,
      26,
    )..addPath(_circle(w / 2 + 22, 50, 26), Offset.zero),
    RgSymbol.passing => _circle(
      w / 2,
      50,
      20,
    )..addPath(_line(6, 50, w - 6, 50), Offset.zero),
    RgSymbol.circle => _circle(50, 50, 38),
    RgSymbol.rotationAxis => _circle(
      50,
      50,
      38,
    )..addPath(_line(12, 50, 88, 50), Offset.zero),
    RgSymbol.rotationAxisFloor =>
      _circle(w / 2, 42, 32)
        ..addPath(_line(w / 2, 10, w / 2, 74), Offset.zero)
        ..addPath(_floor(w, 86), Offset.zero),
    RgSymbol.figureEight => _circle(
      w / 2,
      28,
      22,
    )..addPath(_circle(w / 2, 72, 22), Offset.zero),
    RgSymbol.catchOneHand =>
      _line(w / 2, 5, w / 2, 90)..addPath(
        Path()
          ..moveTo(w / 2 - 22, 66)
          ..quadraticBezierTo(w / 2 - 20, 94, w / 2, 94)
          ..quadraticBezierTo(w / 2 + 20, 94, w / 2 + 22, 66),
        Offset.zero,
      ),
    RgSymbol.rebound =>
      (Path()
          ..moveTo(18, 5)
          ..lineTo(18, 92)
          ..lineTo(80, 45))
        ..addPath(_head(18, 92, 80, 45), Offset.zero),
    RgSymbol.bounces =>
      Path()
        ..moveTo(8, 15)
        ..lineTo(40, 85)
        ..lineTo(72, 15),
    RgSymbol.mill => _line(
      14,
      14,
      86,
      86,
    )..addPath(_line(86, 14, 14, 86), Offset.zero),
    RgSymbol.asymmetry => _line(
      50,
      8,
      50,
      92,
    )..addPath(_line(8, 50, 92, 50), Offset.zero),
    RgSymbol.smallThrowTwoClubs =>
      _line(6, 40, w - 20, 40)
        ..addPath(_line(6, 60, w - 20, 60), Offset.zero)
        ..addPath(
          Path()
            ..moveTo(w - 34, 22)
            ..lineTo(w - 6, 50)
            ..lineTo(w - 34, 78),
          Offset.zero,
        ),
    RgSymbol.smallThrowLockedClubs => _line(6, 50, w - 6, 50),
    RgSymbol.smallCirclesBothClubs => _circle(
      w / 2 - 12,
      50,
      36,
    )..addPath(_circle(w / 2 + 12, 50, 36), Offset.zero),
    RgSymbol.spiral => _coil(w),
    RgSymbol.swordsman => _coil(
      w,
    )..addPath(_line(w - 12, 4, 12, 96), Offset.zero),
    RgSymbol.snake => _zigzag(w),
    RgSymbol.boomerang =>
      Path()
        ..moveTo(6, 90)
        ..quadraticBezierTo(50, 26, 118, 14)
        ..quadraticBezierTo(146, 12, 138, 24)
        ..quadraticBezierTo(108, 40, 72, 48)
        ..lineTo(142, 66),
    RgSymbol.echappe =>
      (Path()
          ..moveTo(6, 92)
          ..cubicTo(50, 66, 88, 26, 66, 22)
          ..cubicTo(50, 22, 46, 62, 74, 50)
          ..lineTo(122, 12))
        ..addPath(_head(74, 50, 122, 12), Offset.zero),
    RgSymbol.highThrowFromSliding =>
      (Path()
          ..moveTo(6, 66)
          ..cubicTo(14, 104, 52, 100, 56, 8))
        ..addPath(_head(52, 60, 56, 8), Offset.zero),
    RgSymbol.highThrow => _arrow(14, 86, 86, 14),
    RgSymbol.highThrowWithRotation => _circle(
      44,
      56,
      26,
    )..addPath(_arrow(12, 90, 88, 12), Offset.zero),
    RgSymbol.highThrowTwoClubs =>
      _line(8, 78, 66, 20)
        ..addPath(_line(22, 92, 80, 34), Offset.zero)
        ..addPath(
          Path()
            ..moveTo(44, 12)
            ..lineTo(90, 10)
            ..lineTo(88, 56),
          Offset.zero,
        ),
    RgSymbol.catchHighThrow => _arrow(w / 2, 8, w / 2, 92),
    RgSymbol.catchTwoClubs =>
      _line(w / 2 - 9, 6, w / 2 - 9, 76)
        ..addPath(_line(w / 2 + 9, 6, w / 2 + 9, 76), Offset.zero)
        ..addPath(
          Path()
            ..moveTo(w / 2 - 26, 62)
            ..lineTo(w / 2, 94)
            ..lineTo(w / 2 + 26, 62),
          Offset.zero,
        ),
    RgSymbol.smallThrow => _arrow(6, 50, w - 6, 50),
    RgSymbol.underFlightJump =>
      _arc()..addPath(
        Path()
          ..moveTo(32, 88)
          ..lineTo(50, 54)
          ..lineTo(68, 88),
        Offset.zero,
      ),
    RgSymbol.underFlightBalance =>
      _arc()
        ..addPath(_line(32, 46, 68, 46), Offset.zero)
        ..addPath(_line(50, 46, 50, 90), Offset.zero),
    RgSymbol.underFlightRotation =>
      _arc()
        ..addPath(_circle(50, 78, 12), Offset.zero)
        ..addPath(_line(50, 32, 50, 66), Offset.zero),
    RgSymbol.outsideVisualField =>
      _circle(50, 50, 26)
        ..addPath(_line(14, 14, 86, 86), Offset.zero)
        ..addPath(_line(86, 14, 14, 86), Offset.zero),
    RgSymbol.withoutHands =>
      _line(50, 8, 50, 92)
        ..addPath(_line(18, 38, 82, 38), Offset.zero)
        ..addPath(_line(18, 62, 82, 62), Offset.zero),
    RgSymbol.underLeg => _line(
      8,
      50,
      92,
      50,
    )..addPath(_line(28, 74, 74, 26), Offset.zero),
    RgSymbol.positionOnFloor => _line(
      10,
      39,
      90,
      39,
    )..addPath(_line(10, 61, 90, 61), Offset.zero),
    RgSymbol.fullBodyWave =>
      Path()
        ..moveTo(8, 22)
        ..lineTo(29, 80)
        ..lineTo(50, 34)
        ..lineTo(71, 80)
        ..lineTo(92, 22),
    RgSymbol.changeOfAxisOrLevel =>
      (Path()
          ..moveTo(16, 16)
          ..lineTo(84, 16)
          ..lineTo(16, 84)
          ..lineTo(84, 84))
        ..addPath(_line(24, 50, 76, 50), Offset.zero),
    RgSymbol.series =>
      Path()
        ..moveTo(78, 24)
        ..cubicTo(60, 0, 18, 8, 22, 34)
        ..cubicTo(26, 58, 80, 46, 78, 72)
        ..cubicTo(76, 98, 30, 96, 18, 76),
    RgSymbol.directRebound =>
      Path()
        ..moveTo(20, 12)
        ..lineTo(20, 86)
        ..lineTo(76, 56),
    RgSymbol.catchWithRoll => _loops(
      w,
      60,
    )..addPath(_arrow(w / 2, 4, w / 2, 62), Offset.zero),
    RgSymbol.catchWithRotation =>
      (Path()..addArc(
          Rect.fromCircle(center: const Offset(50, 50), radius: 38),
          0.2,
          -5.6,
        ))
        ..addPath(
          Path()
            ..moveTo(50, 50)
            ..lineTo(86, 56)
            ..lineTo(90, 90),
          Offset.zero,
        ),
    RgSymbol.ropeSkips =>
      Path()
        ..moveTo(6, 66)
        ..lineTo(36, 34)
        ..lineTo(60, 66)
        ..lineTo(90, 34)
        ..lineTo(114, 66)
        ..lineTo(144, 34),
    RgSymbol.ropeCatchEnds =>
      Path()
        ..moveTo(8, 84)
        ..quadraticBezierTo(24, 88, 28, 56)
        ..cubicTo(30, 6, 70, 6, 72, 56)
        ..quadraticBezierTo(76, 88, 92, 84),
    RgSymbol.ropeOpenRotation => _line(
      22,
      34,
      w - 6,
      34,
    )..addPath(_line(6, 68, w - 6, 68), Offset.zero),
    RgSymbol.highThrowOpenRopeMiddle => _line(
      20,
      30,
      w - 10,
      30,
    )..addPath(_arrow(22, 90, w / 2, 34), Offset.zero),
    RgSymbol.highThrowOpenRopeEnd => _line(
      58,
      30,
      w - 6,
      30,
    )..addPath(_arrow(10, 90, 56, 34), Offset.zero),
    RgSymbol.ropeBackward => _arrow(w - 6, 50, 6, 50),
    RgSymbol.duringDb =>
      (Path()
          ..moveTo(10, 20)
          ..lineTo(10, 80)
          ..cubicTo(72, 86, 72, 14, 10, 20))
        ..addPath(
          Path()
            ..moveTo(70, 20)
            ..lineTo(70, 80)
            ..cubicTo(128, 86, 124, 46, 70, 50)
            ..cubicTo(118, 46, 116, 14, 70, 20),
          Offset.zero,
        ),
    RgSymbol.rotation => _line(
      w / 2,
      6,
      w / 2,
      58,
    )..addPath(_circle(w / 2, 74, 18), Offset.zero),
  };

  /// The filled heads of locked Clubs, and the hands on an open Rope.
  List<Rect> _dots(double w) {
    Rect dot(double x, double y, double width, double height) =>
        Rect.fromCenter(center: Offset(x, y), width: width, height: height);
    return switch (symbol) {
      RgSymbol.smallThrowLockedClubs => [
        dot(w / 2 - 6, 50, 34, 20),
        dot(w - 22, 50, 26, 18),
      ],
      RgSymbol.ropeOpenRotation => [
        dot(22, 34, 16, 16),
        dot(w / 2, 68, 22, 16),
      ],
      RgSymbol.highThrowOpenRopeMiddle => [dot(w / 2, 30, 16, 16)],
      RgSymbol.highThrowOpenRopeEnd => [dot(58, 30, 16, 16)],
      _ => const [],
    };
  }

  static Path _line(double x1, double y1, double x2, double y2) => Path()
    ..moveTo(x1, y1)
    ..lineTo(x2, y2);

  static Path _circle(double x, double y, double radius) =>
      Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));

  static Path _floor(double w, double y) => _line(6, y, w - 6, y);

  static Path _arrow(double x1, double y1, double x2, double y2) =>
      _line(x1, y1, x2, y2)..addPath(_head(x1, y1, x2, y2), Offset.zero);

  /// The head of an arrow going from (x1, y1) to (x2, y2).
  static Path _head(double x1, double y1, double x2, double y2) {
    const length = 30.0;
    final angle = math.atan2(y2 - y1, x2 - x1);
    Offset wing(double side) => Offset(
      x2 - length * math.cos(angle + side),
      y2 - length * math.sin(angle + side),
    );
    final a = wing(0.55);
    final b = wing(-0.55);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(x2, y2)
      ..lineTo(b.dx, b.dy);
  }

  /// The flight of the apparatus over a DB (#3.4.3).
  static Path _arc() => Path()
    ..moveTo(6, 94)
    ..cubicTo(6, -10, 94, -10, 94, 94);

  /// Three loops hanging from a line, like a handwritten "ooo".
  static Path _loops(double w, double centre) {
    const reach = 8.0;
    const swing = 20.0;
    const height = 30.0;
    final path = Path();
    for (var i = 0; i <= 160; i++) {
      final t = -math.pi + i / 160 * 6 * math.pi;
      final x = (w - reach * 6 * math.pi) / 2 + reach * (t + math.pi);
      final point = Offset(
        x - swing * math.sin(t),
        centre + height * math.cos(t),
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  /// Tight loops one above the other (a Ribbon spiral).
  static Path _coil(double w) {
    const loops = 4;
    final path = Path();
    for (var i = 0; i <= 200; i++) {
      final t = -math.pi / 2 + i / 200 * loops * 2 * math.pi;
      final y = 13 + (i / 200) * 74 + 12 * math.sin(t);
      final point = Offset(w / 2 + (w / 2 - 8) * math.cos(t), y);
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  /// A Ribbon snake: waves down the height.
  static Path _zigzag(double w) {
    const waves = 4;
    final path = Path()..moveTo(8, 5);
    for (var i = 1; i <= waves * 2; i++) {
      path.lineTo(i.isOdd ? w - 8 : 8, 5 + i * 90 / (waves * 2));
    }
    return path;
  }

  @override
  bool shouldRepaint(RgSymbolPainter oldDelegate) =>
      oldDelegate.symbol != symbol || oldDelegate.color != color;
}
