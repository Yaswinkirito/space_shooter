// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';
import 'package:space_shooter/components/game.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';

import '../games_services/score.dart';

import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';

class PlaySessionScreen extends StatefulWidget {
  final GameLevel level;

  const PlaySessionScreen(this.level, {super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;
  final game = SpaceShooter();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LevelState(
            goal: widget.level.difficulty,
            onWin: _playerWon,
          ),
        ),
      ],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Scaffold(
          backgroundColor: palette.backgroundPlaySession,
          body: Stack(
            children: [
              Center(
                  child: GameWidget(
                game: game,
                overlayBuilderMap: {
                  'PauseButton': (BuildContext context, SpaceShooter game) {
                    return PauseButton(game);
                  },
                  'GameOver': (BuildContext context, SpaceShooter game) {
                    return GameOver(game: game);
                  },
                  'PauseMenu': (BuildContext context, SpaceShooter game) {
                    return PauseMenu(game: game);
                  }
                },
              )
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Align(
                  //       alignment: Alignment.centerRight,
                  //       child: InkResponse(
                  //         onTap: () => GoRouter.of(context).push('/settings'),
                  //         child: Image.asset(
                  //           'assets/images/settings.png',
                  //           semanticLabel: 'Settings',
                  //         ),
                  //       ),
                  //     ),
                  //     const Spacer(),
                  //     Text('Drag the slider to ${widget.level.difficulty}%'
                  //         ' or above!'),
                  //     Consumer<LevelState>(
                  //       builder: (context, levelState, child) => Slider(
                  //         label: 'Level Progress',
                  //         autofocus: true,
                  //         value: levelState.progress / 100,
                  //         onChanged: (value) =>
                  //             levelState.setProgress((value * 100).round()),
                  //         onChangeEnd: (value) => levelState.evaluate(),
                  //       ),
                  //     ),
                  //     const Spacer(),
                  //     Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: SizedBox(
                  //         width: double.infinity,
                  //         child: FilledButton(
                  //           onPressed: () => GoRouter.of(context).go('/play'),
                  //           child: const Text('Back'),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  ),
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(
                      isStopped: !_duringCelebration,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();
    Flame.device.fullScreen();

    // Preload ad for the win screen.
  }

  Future<void> _playerWon() async {
    _log.info('Level ${widget.level.number} won');

    final score = Score(
      widget.level.number,
      widget.level.difficulty,
      DateTime.now().difference(_startOfPlay),
    );

    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelReached(widget.level.number);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}

class PauseMenu extends StatefulWidget {
  final SpaceShooter game;
  const PauseMenu({required this.game, super.key});

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
              child: SizedBox(
            child: ListTile(
              textColor: Colors.blue,
              title: Center(
                child: Text(
                  "Pause Menu",
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
          )),
          Row(
            children: [
              Expanded(flex: 10, child: SizedBox()),
              Expanded(
                flex: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.play_arrow,
                    size: 50,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {});

                    widget.game.resumeEngine();
                    widget.game.overlays.remove("PauseMenu");
                  },
                ),
              ),
              const Expanded(
                  flex: 50,
                  child: Text(
                    "Resume",
                    style: TextStyle(color: Colors.blue, fontSize: 30),
                  )),
            ],
          ),
          Row(
            children: [
              Expanded(flex: 10, child: SizedBox()),
              Expanded(
                  flex: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings,
                      size: 40,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      GoRouter.of(context).go('/Settings');
                    },
                  )),
              const Expanded(
                  flex: 50,
                  child: Text(
                    "Setting",
                    style: TextStyle(color: Colors.blue, fontSize: 30),
                  )),
            ],
          ),
          Row(
            children: [
              Expanded(flex: 10, child: SizedBox()),
              Expanded(
                  flex: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.home,
                      size: 40,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      GoRouter.of(context).go('/');
                    },
                  )),
              const Expanded(
                  flex: 50,
                  child: Text(
                    "Home",
                    style: TextStyle(color: Colors.blue, fontSize: 30),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class PauseButton extends StatefulWidget {
  final SpaceShooter game;

  PauseButton(this.game, {super.key});

  @override
  State<PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<PauseButton> {
  var state = true;

  @override
  Widget build(BuildContext context) {
    return ButtonMethod();
  }

  IconButton ButtonMethod() {
    return IconButton(
        onPressed: () {
          if (state) {
            setState(() {
              state = false;
              widget.game.overlays.add("PauseMenu");
            });
            widget.game.pauseEngine();
          } else {
            setState(() {
              state = true;
              widget.game.resumeEngine();
              widget.game.overlays.remove("PauseMenu");
            });
          }
        },
        icon: const Icon(
          Icons.pause,
          color: Colors.white,
        ));
  }
}

class GameOver extends StatefulWidget {
  final SpaceShooter game;
  const GameOver({required this.game, super.key});

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  @override
  Widget build(BuildContext context) {
    widget.game.pauseEngine();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(flex: 10, child: SizedBox()),
            Expanded(
                flex: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.home,
                    size: 40,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    GoRouter.of(context).go('/');
                  },
                )),
            const Expanded(
                flex: 50,
                child: Text(
                  "Home",
                  style: TextStyle(color: Colors.blue, fontSize: 30),
                )),
          ],
        ),
        Row(
          children: [
            Expanded(flex: 10, child: SizedBox()),
            Expanded(
                flex: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 40,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    widget.game.gameOver = true;
                    widget.game.resumeEngine();
                  },
                )),
            const Expanded(
                flex: 50,
                child: Text(
                  "Restart",
                  style: TextStyle(color: Colors.blue, fontSize: 30),
                )),
          ],
        ),
      ],
    );
  }
}
