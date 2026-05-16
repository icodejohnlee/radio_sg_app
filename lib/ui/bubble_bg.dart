import 'dart:math';
import 'package:flutter/material.dart';

class Bubble {
  double x;
  double y;

  double vx;
  double vy;

  double baseSize;
  double phase;
  Color color;

  Bubble({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.baseSize,
    required this.phase,
    required this.color,
  });
}

class BubbleBg extends StatefulWidget {
  const BubbleBg({super.key});

  @override
  State<BubbleBg> createState() => _BubbleBgState();
}

class _BubbleBgState extends State<BubbleBg>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final random = Random();
  final List<Bubble> bubbles = [];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // slower = calmer
    )..repeat();

    for (int i = 0; i < 20; i++) {
      bubbles.add(Bubble(
        x: random.nextDouble(),
        y: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * 0.0058, // slow drift
        vy: (random.nextDouble() - 0.5) * 0.0028,
        baseSize: random.nextDouble() * 25 + 10,
        phase: random.nextDouble() * pi * 2,
        color: Colors.primaries[random.nextInt(Colors.primaries.length)]
            .withOpacity(0.25),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: BubblePainter(controller.value, bubbles),
        );
      },
    );
  }
}

class BubblePainter extends CustomPainter {
  final double value;
  final List<Bubble> bubbles;

  BubblePainter(this.value, this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.black, Colors.deepPurple, Colors.black],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, bg);

    for (final b in bubbles) {
      // slow movement
      b.x += b.vx;
      b.y += b.vy;

      // soft edge bounce (reflection)
      if (b.x < 0 || b.x > 1) {
        b.vx = -b.vx;
        b.x = b.x.clamp(0.0, 1.0);
      }

      if (b.y < 0 || b.y > 1) {
        b.vy = -b.vy;
        b.y = b.y.clamp(0.0, 1.0);
      }

      // slow breathing size
      final pulse = (sin(value * 2 * pi + b.phase) + 1) / 2;
      final radius = b.baseSize * (0.7 + pulse * 0.6);

      // gentle opacity breathing
      final paint = Paint()
        ..color = b.color.withOpacity(0.15 + pulse * 0.2);

      canvas.drawCircle(
        Offset(b.x * size.width, b.y * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}