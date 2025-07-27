import 'package:flutter/material.dart';
import 'package:connect_game/models/point.dart';

// CustomPainter for the snake path
class SnakePathPainter extends CustomPainter {
  final List<Point> path;
  final int gridSize;
  SnakePathPainter(this.path, this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;
    final paint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = size.width / gridSize * 0.6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final cellSize = size.width / gridSize;
    final points =
        path
            .map(
              (p) => Offset(
                p.col * cellSize + cellSize / 2,
                p.row * cellSize + cellSize / 2,
              ),
            )
            .toList();
    final pathObj = Path();
    pathObj.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      pathObj.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(pathObj, paint);
  }

  @override
  bool shouldRepaint(covariant SnakePathPainter oldDelegate) {
    return oldDelegate.path != path;
  }
}
