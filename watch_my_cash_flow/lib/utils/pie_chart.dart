import 'dart:math';

import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final double size;
  final List<double> values;
  const PieChart({super.key, required this.values, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: PieChartPainter(values: values),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> values;
  final int startIndex;

  PieChartPainter({
    required this.values,
    this.startIndex = 0,
    // required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.reduce((a, b) => a + b);
    double startAngle = -pi / 2;

    final radius = size.width / 2;
    final center = Offset(radius, radius);

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * pi;
      paint.color = modernChartColors[i + startIndex];

      // Draw slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // ---- Draw text ----
      final midAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.6;

      final textOffset = Offset(
        center.dx + cos(midAngle) * textRadius,
        center.dy + sin(midAngle) * textRadius,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: values[i].toString(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

const List<Color> mutedChartColors = [
  Color(0xFF6366F1),
  Color(0xFF0EA5E9),
  Color(0xFF22C55E),
  Color(0xFFEAB308),
  Color(0xFFF87171),
  Color(0xFFA855F7),
  Color(0xFFF472B6),
  Color(0xFF2DD4BF),
  Color(0xFF4ADE80),
  Color(0xFF94A3B8),
];

const List<Color> modernChartColors = [
  Color(0xFF4F46E5), // Indigo
  Color(0xFF06B6D4), // Cyan
  Color(0xFF10B981), // Emerald
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
  Color(0xFF8B5CF6), // Violet
  Color(0xFFEC4899), // Pink
  Color(0xFF14B8A6), // Teal
  Color(0xFF22C55E), // Green
  Color(0xFF64748B), // Slate
];