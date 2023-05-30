import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:space_shooter/components/enemy.dart';

class Player extends SpriteComponent with HasGameRef, CollisionCallbacks {
  double maxSpeed = 300.0;
  int score = 0;
  int health = 100;
  bool gameOver = false;
  final JoystickComponent joystick;
  final Sprite spaceShip;
  Player(this.joystick, this.spaceShip)
      : super(size: Vector2.all(75.0), anchor: Anchor.center);
  @override
  Future<void> onLoad() async {
    sprite = await spaceShip;
    position = gameRef.size / 2;
    add(RectangleHitbox());
    angle = -pi / 2;
  }

  @override
  void update(double dt) {
    if (!joystick.delta.isZero()) {
      if (position.x < 0) {
        position.x = 0;
      }
      if (position.y < 0) {
        position.y = 0;
      }
      if (position.y > gameRef.size.y) {
        position.y = gameRef.size.y;
      }
      if (position.x > gameRef.size.x) {
        position.x = gameRef.size.x;
      }
      position.add(joystick.relativeDelta * maxSpeed * dt);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Enemy) {
      gameRef.camera.shake();
      score += 10;
      health -= 10;
      if (health <= 0) {
        health = 0;
      }
    }
  }
}
