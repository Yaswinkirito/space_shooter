import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Bullet extends SpriteComponent {
  double maxSpeed = 450;
  final Sprite bullet;
  Vector2 position1;
  Bullet(this.bullet, this.position1)
      : super(size: Vector2.all(100), anchor: Anchor.center);
  @override
  Future<void> onLoad() async {
    sprite = bullet;
    position = position1;
    add(RectangleHitbox());
    angle = -pi / 2;
  }

  @override
  void update(dt) {
    super.update(dt);
    position += Vector2(0, -1) * maxSpeed * dt;
    if (position.y < 0) {
      removeFromParent();
    }
  }
}
