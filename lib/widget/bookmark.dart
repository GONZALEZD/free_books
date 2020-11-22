import 'package:flutter/material.dart';

class BookmarkWidget extends StatelessWidget {

  final Color _color;
  final Gradient _gradient;
  final Widget icon;

  BookmarkWidget({@required Color color, Color colorDarker, this.icon}):
      _color = colorDarker==null ? color : null,
  _gradient = colorDarker==null ? null : LinearGradient(
    colors: [color, colorDarker],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.loose,
          children: [
            CustomPaint(
              size: constraints.biggest,
              willChange: false,
              painter: _BookmarkPainter(
                color: _color,
                gradient: _gradient,
              ),
            ),
            if (icon != null) icon,
          ],
        );
      },
    );
  }
}

class _BookmarkPainter extends CustomPainter {
  final Color color;
  final Gradient gradient;

  _BookmarkPainter({this.color, this.gradient}):
      assert(color != null || gradient != null);

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createShape(size.width, size.height);
    final paint = _createPaint(Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)));
    canvas.drawPath(path, paint);
  }

  Paint _createPaint(Rect bounds) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill;

    if(this.color != null) {
      paint.color = this.color;
    }
    else {
      paint.shader = this.gradient.createShader(bounds);
    }
    return paint;
  }

  Path _createShape(double width, double height) {
    Path path = Path();
    
    path.addPolygon([
      Offset.zero,
      Offset(width, 0.0),
      Offset(width, height),
      Offset(width / 2, height * 0.75),
      Offset(0.0, height),
    ], true);
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if(oldDelegate is _BookmarkPainter) {
      return oldDelegate.color != this.color || oldDelegate.gradient != this.gradient;
    }
    return true;
  }
}
