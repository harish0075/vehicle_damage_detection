import 'dart:io';
import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> damages;
  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter({
    required this.damages,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (damages.isEmpty) return;

    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;

    for (final damage in damages) {
      final bbox = damage['bbox'] as List?;
      if (bbox == null || bbox.length != 4) continue;

      final x = (bbox[0] as num).toDouble() * scaleX;
final y = (bbox[1] as num).toDouble() * scaleY;
      final width = (bbox[2] as num).toDouble() * scaleX;
      final height = (bbox[3] as num).toDouble() * scaleY;

      final severity = damage['severity'] as String? ?? 'Unknown';
      final color = _getSeverityColor(severity);
      final confidence = damage['confidence'] as num? ?? 0.0;
      final type = damage['type'] as String? ?? 'Unknown';

      // Draw bounding box rectangle
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRect(
        Rect.fromLTWH(x, y, width, height),
        paint,
      );

      // Draw label background
      final label = '$type (${(confidence * 100).toStringAsFixed(0)}%)';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Draw label background rectangle
      final labelRect = Rect.fromLTWH(
        x,
        y - textPainter.height - 8,
        textPainter.width + 12,
        textPainter.height + 8,
      );

      final labelPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRect(labelRect, labelPaint);

      // Draw label text
      textPainter.paint(
        canvas,
        Offset(x + 6, y - textPainter.height - 4),
      );
    }
  }

  Color _getSeverityColor(String severity) {
    final lower = severity.toLowerCase();
    if (lower.contains('critical')) return Colors.red.shade700;
    if (lower.contains('severe')) return Colors.orange.shade700;
    if (lower.contains('moderate')) return Colors.yellow.shade700;
    return Colors.blue.shade700;
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return damages != oldDelegate.damages;
  }
}

/// Widget to display an image with bounding boxes drawn on top
class BoundingBoxImage extends StatelessWidget {
  final File imageFile;
  final List<Map<String, dynamic>> damages;
  final double imageWidth;
  final double imageHeight;

  const BoundingBoxImage({
    super.key,
    required this.imageFile,
    required this.damages,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: imageWidth / imageHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
            CustomPaint(
              painter: BoundingBoxPainter(
                damages: damages,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
