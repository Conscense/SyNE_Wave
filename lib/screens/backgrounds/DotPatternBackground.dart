import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../constants.dart';

class DotPatternBackground extends StatefulWidget {
  final Color backgroundColor;
  final Color dotColor;

  const DotPatternBackground({
    super.key,
    this.backgroundColor = Colors.black, // default dark
    this.dotColor = Colors.white,        // default white dots
  });

  @override
  State<DotPatternBackground> createState() => _DotPatternBackgroundState();
}

class _DotPatternBackgroundState extends State<DotPatternBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 9999), // effectively infinite
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // use continuous time instead of looping phase
          final t = _controller.lastElapsedDuration?.inMilliseconds ?? 0;
          final time = t / 1000.0; // seconds, keeps increasing
          return CustomPaint(
            size: Size.infinite,
            painter: _DotPainter(
              dotColor: widget.dotColor,
              time: time,
            ),
          );
        },
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final double dotSpacing = 20;
  final double dotSize = 2;
  final Color dotColor;
  final double time;

  _DotPainter({required this.dotColor, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxDistance = center.distance;

    const blobCount = 5;
    final List<_Blob> blobs = List.generate(blobCount, (i) {
      final angle = i * 2 * math.pi / blobCount + time * 0.3;
      final radius = size.shortestSide * 0.25;
      final offset = Offset(
        center.dx + radius * math.cos(angle + i * 0.7 + time * 0.15),
        center.dy + radius * math.sin(angle + i * 1.1 + time * 0.1),
      );

      final pulse = 1 + 0.5 * math.sin(time * 1.5 + i);
      return _Blob(center: offset, influence: dotSpacing * 10 * pulse);
    });

    for (double y = -dotSpacing; y < size.height + dotSpacing;
    y += dotSpacing * 0.57735) {
      final offsetX =
      (y ~/ (dotSpacing * 0.57735)) % 2 == 0 ? 0 : dotSpacing / 2;
      for (double x = -dotSpacing;
      x < size.width + dotSpacing;
      x += dotSpacing) {
        final pos = Offset(x + offsetX, y);

        // edge fade
        final distance = (pos - center).distance;
        final distanceFade =
        (1 - (distance / maxDistance)).clamp(0.0, 1.0);

        // closest blob fade
        double nearestBlobFade = 0.0;
        for (final blob in blobs) {
          final d = (pos - blob.center).distance;
          final fade = (1 - (d / blob.influence)).clamp(0.0, 1.0);
          if (fade > nearestBlobFade) nearestBlobFade = fade;
        }

        // blend blob + edge fade
        final fade = (nearestBlobFade * 0.75 + distanceFade * 0.25)
            .clamp(0.0, 1.0);

        final paint = Paint()
          ..color = dotColor.withOpacity(0.05 + 0.95 * fade);

        canvas.drawCircle(pos, dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.dotColor != dotColor;
}

class _Blob {
  final Offset center;
  final double influence;

  _Blob({required this.center, required this.influence});
}
