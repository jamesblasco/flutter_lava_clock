import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'ball.dart';

class LavaPainter extends CustomPainter {
  final Lava lava;
  final Color color;

  LavaPainter(this.lava, {@required this.color})
      : assert(lava != null, 'lava param cannot be null'),
        assert(color != null, 'You need to provide a color');

  @override
  void paint(Canvas canvas, Size size) {
    if (lava.size != size) lava.updateSize(size);
    lava.draw(canvas, size, color, debug: false);
  }

  @override
  bool shouldRepaint(LavaPainter paint) {
    return true;
  }
}

class Lava {
  num step = 5;
  Size size;

  double get width => size.width;

  double get height => size.height;

  Rect sRect;

  double get sx => (this.width ~/ this.step).floor().toDouble();

  double get sy => (this.height ~/ this.step).floor().toDouble();

  bool paint = false;
  double iter = 0;
  int sign = 1;

  Map<int, Map<int, ForcePoint<double>>> matrix;

  List<Ball> balls;
  int ballsLength;

  Lava(this.ballsLength) {}

  updateSize(Size size) {
    this.size = size;
    this.sRect = Rect.fromCenter(
        center: Offset.zero, width: sx.toDouble(), height: sy.toDouble());

    this.matrix = {};
    print(sx);
    print(sRect.left - step);
    for (int i = (sRect.left - step).toInt(); i < sRect.right + step; i++) {
      this.matrix[i] = {};
      for (int j = (sRect.top - step).toInt(); j < sRect.bottom + step; j++) {
        this.matrix[i][j] = new ForcePoint(
            (i + this.sx ~/ 2).toDouble() * this.step,
            (j + this.sy ~/ 2).toDouble() * this.step);
      }
    }
    balls = List.filled(ballsLength, null);
    for (var index = 0; ballsLength > index; index++)
      this.balls[index] = Ball(size);
  }

  double computeForce(int sx, int sy) {
    var force;
    if (!sRect.contains(Offset(sx.toDouble(), sy.toDouble()))) {
      force = .6 * this.sign;
    } else {
      force = 0;
      final point = this.matrix[sx][sy];
      for (final ball in balls)
        force += ball.size *
            ball.size /
            (-2 * point.x * ball.pos.x -
                2 * point.y * ball.pos.y +
                ball.pos.magnitude +
                point.magnitude);
      force *= this.sign;
    }

    this.matrix[sx][sy].force = force;
    return force;
  }

  final List<int> plx = [0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0];
  final List<int> ply = [0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1];
  final List<int> mscases = [0, 3, 0, 3, 1, 3, 0, 3, 2, 2, 0, 2, 1, 1, 0];
  final ix = [1, 0, -1, 0, 0, 1, 0, -1, -1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1];

  List marchingSquares(List params, Path path) {
    int sx = params[0];
    int sy = params[1];
    int pdir = params[2];

    if (this.matrix[sx][sy].computed == this.iter) return null;

    var dir, mscase = 0;
    for (var a = 0; 4 > a; a++) {
      final dx = this.ix[a + 12];
      final dy = this.ix[a + 16];
      double force = this.matrix[sx + dx][sy + dy].force;
      if (force > 0 && this.sign < 0 ||
          force < 0 && this.sign > 0 ||
          force == null ||
          force == 0) force = this.computeForce(sx + dx, sy + dy);
      if (force.abs() > 1) mscase += pow(2, a);
    }

    if (15 == mscase)
      return [sx, sy - 1, null];
    else if (5 == mscase) {
      dir = 2 == pdir ? 3 : 1;
    } else if (10 == mscase) {
      dir = 3 == pdir ? 0 : 2;
    } else {
      dir = this.mscases[mscase];
      this.matrix[sx][sy].computed = this.iter;
    }

    final dx1 = this.plx[4 * dir + 2];
    final dy1 = this.ply[4 * dir + 2];
    final pForce1 = this.matrix[sx + dx1][sy + dy1].force;

    final dx2 = this.plx[4 * dir + 3];
    final dy2 = this.ply[4 * dir + 3];
    final pForce2 = this.matrix[sx + dx2][sy + dy2].force;
    final p = this.step /
        ((pForce1.abs() - 1).abs() / (pForce2.abs() - 1).abs() + 1.0);

    final dxX = this.plx[4 * dir];
    final dyX = this.ply[4 * dir];
    final dxY = this.plx[4 * dir + 1];
    final dyY = this.ply[4 * dir + 1];

    final lineX = this.matrix[sx + dxX][sy + dyX].x + this.ix[dir] * p;
    final lineY = this.matrix[sx + dxY][sy + dyY].y + this.ix[dir + 4] * p;

    if (paint == false)
      path.moveTo(lineX, lineY);
    else
      path.lineTo(lineX, lineY);
    this.paint = true;
    return [sx + this.ix[dir + 4], sy + this.ix[dir + 8], dir];
  }

  draw(Canvas canvas, Size size, Color color, {bool debug = false}) {
    for (Ball ball in balls) ball.moveIn(size);

    try {
      this.iter++;
      this.sign = -this.sign;
      this.paint = false;

      for (Ball ball in balls) {
        Path path = Path();
        List params = [
          (ball.pos.x / this.step - this.sx / 2).round(),
          (ball.pos.y / this.step - this.sy / 2).round(),
          null
        ];
        do {
          params = this.marchingSquares(params, path);
        } while (params != null);
        if (this.paint) {
          path.close();

          Paint paint = Paint()..color = color;

          canvas.drawPath(path, paint);

          this.paint = false;
        }
      }
    } catch (e) {
      print(e);
    }

    if (debug) {
      balls.forEach((ball) => canvas.drawCircle(
          Offset(ball.pos.x.toDouble(), ball.pos.y.toDouble()),
          ball.size,
          Paint()..color = Colors.black.withOpacity(0.5)));

      matrix.forEach((_, item) => item.forEach((_, point) => canvas.drawCircle(
          Offset(point.x.toDouble(), point.y.toDouble()),
          max(1, min(point.force.abs(), 5)),
          Paint()..color = point.force > 0 ? Colors.blue : Colors.red)));
    }
  }
}
