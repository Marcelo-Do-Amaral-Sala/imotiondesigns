import 'package:flutter/material.dart';

class RayoLoader extends StatefulWidget {
  final Duration duration;

  const RayoLoader({Key? key, required this.duration}) : super(key: key);

  @override
  _RayoLoaderState createState() => _RayoLoaderState();
}

class _RayoLoaderState extends State<RayoLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(200, 400),
          painter: RayoPainter(progress: _controller.value),
        );
      },
    );
  }
}

class RayoPainter extends CustomPainter {
  final double progress;

  RayoPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final Paint fillPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final Path rayoPath = Path();
    rayoPath.moveTo(size.width * 0.4, 0);
    rayoPath.lineTo(size.width * 0.6, size.height * 0.4);
    rayoPath.lineTo(size.width * 0.45, size.height * 0.4);
    rayoPath.lineTo(size.width * 0.6, size.height);
    rayoPath.lineTo(size.width * 0.4, size.height * 0.6);
    rayoPath.lineTo(size.width * 0.55, size.height * 0.6);
    rayoPath.close();

    // Clip the area for partial filling
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, size.height * (1 - progress), size.width, size.height));
    canvas.drawPath(rayoPath, fillPaint);
    canvas.restore();

    // Draw the outline of the lightning
    canvas.drawPath(rayoPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant RayoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}