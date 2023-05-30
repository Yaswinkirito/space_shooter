import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter/components/bullet.dart';
import 'package:space_shooter/components/enemy.dart';
import 'package:space_shooter/components/enemy_manager.dart';
import 'package:space_shooter/components/player.dart';
import '';

class SpaceShooter extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Player player;
  late bool gameOver;
  late final JoystickComponent joystick;
  late final EnemyManager enemy;
  late TextComponent _playerScore;
  late double time;
  late TextComponent _playerHealth;
  late SpriteSheet spriteSheet;
  late Bullet bullet;
  final Random _random = Random();
  late SpriteSheet ships;
  late SpriteComponent thrust;
  late Sprite bulletSprite;
  late Sprite enemythrust;
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  }

  @override
  Future<void> onLoad() async {
    await images.load('simpleSpace_tilesheet@2.png');
    spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: images.fromCache('simpleSpace_tilesheet@2.png'),
      columns: 8,
      rows: 6,
    );
    await images.load('bullet.png');
    bulletSprite = Sprite(images.fromCache('bullet.png'));
    await images.load('enemythrust.png');
    enemythrust = Sprite(images.fromCache('enemythrust.png'));
    await images.load('bluedestroyer.png');
    final playerSprite = Sprite(images.fromCache('bluedestroyer.png'));
    await images.load('Daco_34496.png');
    final enemySprite = Sprite(images.fromCache('Daco_34496.png'));
    final Images = [
      loadParallaxImage(
        "bg1.png",
        repeat: ImageRepeat.repeatY,
        alignment: Alignment.center,
        fill: LayerFill.width,
      ),
      loadParallaxImage(
        "bg1.png",
        repeat: ImageRepeat.repeatY,
        alignment: Alignment.topRight,
        fill: LayerFill.height,
      ),
      loadParallaxImage(
        'bg2.png',
        repeat: ImageRepeat.repeatY,
        alignment: Alignment.bottomLeft,
        fill: LayerFill.none,
      )
    ];
    final layers = Images.map((images) async => ParallaxLayer(await images,
        velocityMultiplier: Vector2(0, -Images.indexOf(images) * 2.0)));
    final parallaxComponent = Parallax(
      await Future.wait(layers),
      baseVelocity: Vector2(0, 50),
    );
    add(ParallaxComponent(parallax: parallaxComponent));
    final knobPaint = BasicPalette.white.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.white.withAlpha(100).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    gameOver = false;
    player = Player(joystick, playerSprite);
    final bulletButton = HudButtonComponent(
        button: CircleComponent(radius: 30, paint: knobPaint),
        margin: const EdgeInsets.only(
          right: 40,
          bottom: 60,
        ),
        onPressed: () => {
              bullet = Bullet(bulletSprite, player.position.clone()),
              add(bullet)
            });

    enemy = EnemyManager(enemySprite, player, enemythrust);
    add(enemy);
    add(player);
    add(joystick);
    add(bulletButton);
    _playerScore = TextComponent(
      text: "Score: 0",
      position: Vector2(10, 50),
      textRenderer:
          TextPaint(style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
    _playerScore = TextComponent(
      text: "Score: 0",
      position: Vector2(10, 50),
      textRenderer:
          TextPaint(style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
    add(_playerScore);
    _playerHealth = TextComponent(
      text: "Health: 100%",
      position: Vector2(size.x - 10, 10),
      textRenderer:
          TextPaint(style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
    _playerHealth.anchor = Anchor.topRight;

    add(_playerHealth);
    overlays.add("PauseButton");
    thrust = SpriteComponent(
        sprite: bulletSprite,
        position: player.position.clone() + Vector2(0, player.size.y / 3));
    add(thrust);
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.gameOver = false;
    if (gameOver == false) {
      overlays.remove("GameOver");
    }
    remove(thrust);
    String health = player.health.toString();
    String score = player.score.toString();
    _playerHealth.text = "Health: $health%";
    _playerScore.text = "Score: $score";
    if ((player.health <= 0) & (!camera.shaking)) {
      overlays.add("GameOver");
    }
    if (gameOver == true) {
      player.gameOver = true;
      player.health = 100;
      player.position = size / 2;
      player.anchor = Anchor.center;
      player.score = 0;
    }
    thrust = SpriteComponent(
        sprite: bulletSprite,
        position: player.position.clone() + Vector2(0, player.size.y / 2),
        angle: -pi / 2,
        anchor: Anchor.center);
    add(thrust);

    gameOver = false;
  }
}
