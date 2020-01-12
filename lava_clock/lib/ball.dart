import 'dart:math';
import 'dart:ui';

class ForcePoint<T extends num> {
  T x, y;

  T get magnitude => x * x + y * y;

  ForcePoint(this.x, this.y);

  double computed = 0;
  double force = 0;

  ForcePoint<T> add<T extends num>(ForcePoint<T> point) =>
      ForcePoint(point.x + this.x, point.y + this.y);

  ForcePoint copyWith({T x, T y}) => ForcePoint(x ?? this.x, y ?? this.y);
}

class Ball {
  ForcePoint velocity;
  ForcePoint pos;
  double size;

  Ball(Size size) {
    double vel({double ratio = 1}) =>
        (Random().nextDouble() > .5 ? 1 : -1) *
        (.2 + .25 * Random().nextDouble());
    velocity = ForcePoint(vel(ratio: 0.25), vel());

    var i = .1;
    var h = 1.5;

    double calculatePosition(double fullSize) =>
        Random().nextDouble() * fullSize;
    pos = ForcePoint(
        calculatePosition(size.width), calculatePosition(size.height));

    this.size = size.shortestSide / 15 +
        (Random().nextDouble() * (h - i) + i) * (size.shortestSide / 15);
  }

  moveIn(Size size) {
    if (this.pos.x >= size.width - this.size) {
      if (this.pos.x > 0) this.velocity.x = -this.velocity.x;
      this.pos = pos.copyWith(x: size.width - this.size);
    } else if (this.pos.x <= this.size) {
      if (this.velocity.x < 0) this.velocity.x = -this.velocity.x;
      this.pos.x = this.size;
    }
    if (this.pos.y >= size.height - this.size) {
      if (this.velocity.y > 0) this.velocity.y = -this.velocity.y;
      this.pos.y = size.height - this.size;
    } else if (this.pos.y <= this.size) {
      if (this.velocity.y < 0) this.velocity.y = -this.velocity.y;
      this.pos.y = this.size;
    }
    this.pos = this.pos.add(this.velocity);
  }
}
