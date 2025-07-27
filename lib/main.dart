import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ConnectGamePage(),
    );
  }
}

class ConnectGamePage extends StatefulWidget {
  const ConnectGamePage({Key? key}) : super(key: key);

  @override
  State<ConnectGamePage> createState() => _ConnectGamePageState();
}

class _ConnectGamePageState extends State<ConnectGamePage> {
  static const int gridSize = 6;
  // Example node positions: (row, col) : number
  final Map<Point, int> nodes = {
    const Point(0, 0): 1,
    const Point(5, 5): 2,
    const Point(3, 1): 3,
    const Point(1, 2): 4,
    const Point(2, 4): 5,
    const Point(3, 2): 6,
    const Point(0, 4): 7,
    const Point(2, 3): 8,
  };

  // Path as a list of points
  List<Point> path = [];
  bool isDragging = false;
  final GlobalKey _gridKey = GlobalKey();

  int get maxNode => nodes.values.reduce((a, b) => a > b ? a : b);

  void startDrag(int row, int col) {
    final point = Point(row, col);
    if (nodes[point] == 1) {
      setState(() {
        path = [point];
        isDragging = true;
      });
    }
  }

  // Only this updateDrag should exist
  void updateDrag(Offset globalPosition) {
    if (!isDragging) return;
    final RenderBox? box =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPosition);
    final cellSize = box.size.width / gridSize;
    final dragRow = (local.dy ~/ cellSize).clamp(0, gridSize - 1);
    final dragCol = (local.dx ~/ cellSize).clamp(0, gridSize - 1);
    final point = Point(dragRow, dragCol);
    if (path.contains(point)) return; // No revisiting
    if (!_isAdjacent(point, path.last)) return; // Only adjacent
    // Only enforce node order when a node is reached
    if (nodes.containsKey(point)) {
      // Find the last node in the path
      int lastNodeNum = 1;
      for (int i = path.length - 1; i >= 0; i--) {
        if (nodes.containsKey(path[i])) {
          lastNodeNum = nodes[path[i]]!;
          break;
        }
      }
      final expected = lastNodeNum + 1;
      if (nodes[point] != expected) return;
    }
    setState(() {
      path.add(point);
      // Check for win
      if (_isWin()) {
        isDragging = false;
        Future.delayed(Duration(milliseconds: 300), () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Congratulations!'),
                  content: const Text(
                    'You connected all the numbers in order!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          path.clear();
                        });
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        });
      }
    });
  }

  void endDrag() {
    setState(() {
      isDragging = false;
    });
  }

  bool _isAdjacent(Point a, Point b) {
    final dr = (a.row - b.row).abs();
    final dc = (a.col - b.col).abs();
    return (dr == 1 && dc == 0) || (dr == 0 && dc == 1);
  }

  bool _isWin() {
    // Check if all nodes are visited in order
    final nodePoints =
        nodes.keys.toList()..sort((a, b) => nodes[a]!.compareTo(nodes[b]!));

    int pathIdx = 0;
    for (int i = 0; i < nodePoints.length; i++) {
      final targetNode = nodePoints[i];
      // Find this node in the path
      bool found = false;
      while (pathIdx < path.length) {
        if (path[pathIdx] == targetNode) {
          found = true;
          pathIdx++;
          break;
        }
        pathIdx++;
      }
      if (!found) return false;
    }
    return true;
  }

  void undo() {
    setState(() {
      if (path.isNotEmpty) {
        path.removeLast();
      }
    });
  }

  void showHint() {
    // Placeholder for hint logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Hint not implemented yet!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Game grid
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              key: _gridKey,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Snake path painter overlay (drawn first)
                  IgnorePointer(
                    child: CustomPaint(
                      key: ValueKey(
                        path.length,
                      ), // Force repaint when path changes
                      size: Size.infinite,
                      painter: SnakePathPainter(path, gridSize),
                    ),
                  ),
                  // Grid cells with numbers (drawn on top)
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      final row = index ~/ gridSize;
                      final col = index % gridSize;
                      final point = Point(row, col);
                      final isNode = nodes.containsKey(point);
                      final nodeNumber = nodes[point];
                      final isInPath = path.contains(point);
                      return GestureDetector(
                        onTap: () {},
                        onPanStart: (_) => startDrag(row, col),
                        onPanUpdate: (details) {
                          updateDrag(details.globalPosition);
                        },
                        onPanEnd: (_) => endDrag(),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isInPath ? Colors.transparent : Colors.white,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child:
                                isNode
                                    ? CircleAvatar(
                                      backgroundColor: Colors.black,
                                      child: Text(
                                        '$nodeNumber',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: undo, child: const Text('Undo')),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: showHint, child: const Text('Hint')),
            ],
          ),
          const SizedBox(height: 16),
          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'How to play',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Connect the numbers in order by dragging from 1 to 2, 3, ...',
                ),
                Text('Only adjacent cells are allowed. No revisiting.'),
                Text('You can undo your last move or get a hint.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for grid points
class Point {
  final int row;
  final int col;
  const Point(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

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
