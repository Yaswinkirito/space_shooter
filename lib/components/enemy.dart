import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter/components/bullet.dart';
import 'package:space_shooter/components/player.dart';

class Enemy extends SpriteComponent with HasGameRef, CollisionCallbacks {
  double maxSpeed = 200.0;
  final Vector2 position1;
  final Sprite spaceShip;
  final Random _random = Random();
  late Player player;
  final Sprite enemythrust;
  late SpriteComponent thrust;
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  }

  Enemy(this.spaceShip, this.position1, this.player, this.enemythrust)
      : super(size: Vector2.all(75));
  @override
  Future<void> onLoad() async {
    sprite = await spaceShip;
    position = position1;
    thrust = SpriteComponent(sprite: enemythrust, position: Vector2(-24.5, 25));
    add(thrust);
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += Vector2(0, 1) * maxSpeed * dt;
    angle = pi;
    if ((position.y > gameRef.size.y) | (player.gameOver == true)) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Bullet) {
      player.score += 10;
      removeFromParent();
      add(ParticleSystemComponent(
          particle: Particle.generate(
              count: 10,
              lifespan: 10,
              generator: (i) => AcceleratedParticle(
                    acceleration: getRandomVector(),
                    speed: getRandomVector(),
                    position: position.clone(),
                    child: CircleParticle(
                        radius: 1, paint: Paint()..color = Colors.white),
                  ))));
    } else if (other is Player) {
      removeFromParent();
    }
  }
}
