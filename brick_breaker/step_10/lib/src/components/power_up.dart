// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'ball.dart';
import 'bat.dart';
import 'double_bat.dart';

enum PowerUpType { doubleBat, ballDuplicate }

class PowerUp extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  PowerUp({
    required super.position,
    required this.powerUpType,
  }) : super(
    size: Vector2(30, 15),
    anchor: Anchor.center,
    paint: Paint()
      ..color = _getColorForType(powerUpType)
      ..style = PaintingStyle.fill,
    children: [RectangleHitbox()],
  );

  final PowerUpType powerUpType;
  static const fallSpeed = 200.0;

  static Color _getColorForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.doubleBat:
        return const Color(0xff8B4513);
      case PowerUpType.ballDuplicate:
        return const Color(0xff00FF00);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;

    // Eliminar si cae fuera de la pantalla
    if (position.y > game.height + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bat || other is DoubleBat) {
      _applyPowerUp();
      removeFromParent();
    }
  }

  void _applyPowerUp() {
    switch (powerUpType) {
      case PowerUpType.doubleBat:
        _activateDoubleBat();
      case PowerUpType.ballDuplicate:
        _duplicateBall();
    }
  }

  void _activateDoubleBat() {
    final mainBat = game.world.children.query<Bat>().firstOrNull;
    if (mainBat != null) {
      final doubleBat = DoubleBat(
        size: mainBat.size,
        cornerRadius: mainBat.cornerRadius,
        position: Vector2(
          game.width - mainBat.position.x,
          mainBat.position.y,
        ),
      );
      game.world.add(doubleBat);
    }
  }

  void _duplicateBall() {
    final existingBall = game.world.children.query<Ball>().firstOrNull;
    if (existingBall != null) {
      final newBall = DuplicatedBall(
        velocity: Vector2(
          -existingBall.velocity.x,
          existingBall.velocity.y,
        ),
        position: existingBall.position,
        radius: existingBall.radius,
        difficultyModifier: existingBall.difficultyModifier,
        duration: 10.0,
      );
      game.world.add(newBall);
    }
  }
}
