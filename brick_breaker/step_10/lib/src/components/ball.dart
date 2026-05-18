// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'bat.dart';
import 'brick.dart';
import 'double_bat.dart';
import 'play_area.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
         radius: radius,
         anchor: Anchor.center,
         paint: Paint()
           ..color = Colors.white
           ..style = PaintingStyle.fill,
         children: [CircleHitbox()],
       );

  final Vector2 velocity;
  final double difficultyModifier;
  bool _removed = false;

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_removed) return;
    
    position += velocity * dt;
    
    // Rebotar en los límites horizontales
    if (position.x < radius) {
      position.x = radius;
      velocity.x = -velocity.x;
    } else if (position.x > game.width - radius) {
      position.x = game.width - radius;
      velocity.x = -velocity.x;
    }
    
    // Rebotar en el límite superior
    if (position.y < radius) {
      position.y = radius;
      velocity.y = -velocity.y;
    }
    
    // Si la bola cae completamente abajo, eliminarla
    if (position.y > game.height) {
      _removed = true;
      removeFromParent();
      
      // Esperar a que se procese la eliminación antes de verificar
      Future.delayed(const Duration(milliseconds: 10), () {
        final balls = game.world.children.query<Ball>();
        final regularBalls = balls.where((b) => b.runtimeType == Ball).toList();
        if (regularBalls.isEmpty) {
          game.playState = PlayState.gameOver;
        }
      });
      return;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayArea) {
      // La lógica de bordes ahora se maneja en update()
      return;
    } else if (other is Bat) {
      velocity.y = -velocity.y;
      velocity.x =
          velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
    } else if (other is DoubleBat) {
      velocity.y = -velocity.y;
      velocity.x =
          velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
    } else if (other is Brick) {
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    }
    
    // Aumentar velocidad en 5% en cada colisión (excepto con el área de juego)
    if (other is! PlayArea) {
      velocity.scale(1.05);
    }
  }
}

class DuplicatedBall extends Ball {
  DuplicatedBall({
    required super.velocity,
    required super.position,
    required super.radius,
    required super.difficultyModifier,
    required this.duration,
  });

  final double duration;
  double _timeAlive = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _timeAlive += dt;

    // Eliminar después de la duración especificada
    if (_timeAlive >= duration) {
      removeFromParent();
    }
  }
}
