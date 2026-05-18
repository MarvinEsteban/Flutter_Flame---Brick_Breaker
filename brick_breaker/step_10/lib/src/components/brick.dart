// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'ball.dart';
import 'bat.dart';
import 'double_bat.dart';
import 'power_up.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Brick({required super.position, required Color color})
    : super(
        size: Vector2(brickWidth, brickHeight),
        anchor: Anchor.center,
        paint: Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        children: [RectangleHitbox()],
      );

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // 20% de probabilidad de generar un power-up
    if (game.rand.nextDouble() < 0.2) {
      _spawnPowerUp();
    }
    
    removeFromParent();
    game.score.value++;

    if (game.world.children.query<Brick>().length == 1) {
      game.playState = PlayState.won;
      game.world.removeAll(game.world.children.query<Ball>());
      game.world.removeAll(game.world.children.query<Bat>());
      game.world.removeAll(game.world.children.query<DoubleBat>());
      game.world.removeAll(game.world.children.query<PowerUp>());
    }
  }

  void _spawnPowerUp() {
    final powerUpType = PowerUpType.values[game.rand.nextInt(PowerUpType.values.length)];
    final powerUp = PowerUp(
      position: position,
      powerUpType: powerUpType,
    );
    game.world.add(powerUp);
  }
}
