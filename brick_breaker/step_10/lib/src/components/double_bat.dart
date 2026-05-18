// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'bat.dart';

class DoubleBat extends PositionComponent
    with HasGameReference<BrickBreaker>, CollisionCallbacks {
  DoubleBat({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center, children: [RectangleHitbox()]);

  final Radius cornerRadius;
  double _timeSinceLastUpdate = 0;
  double _timeAlive = 0;
  static const double _syncInterval = 0.05; // Sincronizar cada 50ms
  static const double _duration = 10.0; // Duración de 10 segundos

  final _paint = Paint()
    ..color = const Color(0xffa85f3f)
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size.toSize(), cornerRadius),
      _paint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceLastUpdate += dt;
    _timeAlive += dt;
    
    // Eliminar después de 10 segundos
    if (_timeAlive >= _duration) {
      removeFromParent();
      return;
    }
    
    // Sincronizar periódicamente con la barra principal
    if (_timeSinceLastUpdate >= _syncInterval) {
      final mainBat = game.world.children.query<Bat>().firstOrNull;
      if (mainBat != null) {
        position.x = (game.width - mainBat.position.x).clamp(size.x / 2, game.width - size.x / 2);
        position.y = mainBat.position.y;
      }
      _timeSinceLastUpdate = 0;
    }
  }

  void moveBy(double dx) {
    position.x = (position.x + dx).clamp(size.x / 2, game.width - size.x / 2);
  }
}
