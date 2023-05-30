import 'dart:math';

import 'package:flame/components.dart';
import 'package:space_shooter/components/enemy.dart';
import 'package:space_shooter/components/player.dart';

class EnemyManager extends Component with HasGameRef {
  late Timer _timer;
  Random random = Random();
  late Player player;
  final Sprite spaceShip;
  final Sprite enemythrust;
  EnemyManager(this.spaceShip, this.player, this.enemythrust) : super() {
    _timer = Timer(2, onTick: _spawnEnemy, repeat: true);
  }
  void _spawnEnemy() {
    Vector2 position = Vector2(random.nextDouble() * gameRef.size.x, 0);
    Enemy enemy = Enemy(spaceShip, position, player, enemythrust);

    add(enemy);
  }

  @override
  void onMount() {
    super.onMount();
    _timer.start();
  }

  @override
  void onRemove() {
    super.onRemove();
    _timer.stop();
  }

  @override
  void update(dt) {
    super.update(dt);
    _timer.update(dt);
  }
}
