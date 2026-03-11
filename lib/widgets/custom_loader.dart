import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_styles/app_colors.dart';

class ClassicLoader extends ConsumerStatefulWidget {
  final double size;

  const ClassicLoader({
    super.key,
    this.size = 48.0,
  });

  @override
  ConsumerState<ClassicLoader> createState() => _ClassicLoaderState();
}

class _ClassicLoaderState extends ConsumerState<ClassicLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner Pulsing Orb
          FadeTransition(
            opacity: TweenSequence<double>([
              TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
              TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
            ]).animate(_controller),
            child: Container(
              width: widget.size * 0.25,
              height: widget.size * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.gold,
                boxShadow: [
                  BoxShadow(
                    color: colors.gold.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          // Spinning Gradient Ring
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ElegantRingPainter(
                    color: colors.gold,
                    strokeWidth: 3.0,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ElegantRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ElegantRingPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Create a sweep gradient that fades out at the tail
    final gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      tileMode: TileMode.repeated,
      colors: [
        color.withOpacity(0.0), // Tail (transparent)
        color.withOpacity(0.1),
        color.withOpacity(0.7),
        color, // Head (solid)
      ],
      stops: const [0.0, 0.2, 0.8, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    // Draw the arc leaving a small gap to emphasize rotation
    // We rotate the canvas so we can just draw a static arc here
    canvas.drawArc(rect, 0.0, 1.8 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ElegantRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
