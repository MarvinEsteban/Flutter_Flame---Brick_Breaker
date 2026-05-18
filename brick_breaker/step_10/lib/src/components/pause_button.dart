// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';

class PauseButton extends PositionComponent with TapCallbacks, HasGameReference<BrickBreaker> {
  PauseButton({
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.topRight);

  bool isPaused = false;

  final _buttonPaint = Paint()
    ..color = const Color(0xff1e6091)
    ..style = PaintingStyle.fill;

  final _iconPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Dibujar el botón redondeado
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(rrect, _buttonPaint);

    // Dibujar el icono (pausa o play)
    if (isPaused) {
      // Icono de play (triángulo)
      final path = Path();
      final centerX = size.x / 2;
      final centerY = size.y / 2;
      final width = size.x * 0.25;
      final height = size.y * 0.4;

      path.moveTo(centerX - width / 2, centerY - height / 2);
      path.lineTo(centerX - width / 2, centerY + height / 2);
      path.lineTo(centerX + width / 2, centerY);
      path.close();

      canvas.drawPath(path, _iconPaint);
    } else {
      // Icono de pausa (dos barras)
      final barWidth = size.x * 0.12;
      final barHeight = size.y * 0.5;
      final centerX = size.x / 2;
      final centerY = size.y / 2;
      final spacing = size.x * 0.08;

      canvas.drawRect(
        Rect.fromLTWH(
          centerX - spacing - barWidth,
          centerY - barHeight / 2,
          barWidth,
          barHeight,
        ),
        _iconPaint,
      );

      canvas.drawRect(
        Rect.fromLTWH(
          centerX + spacing,
          centerY - barHeight / 2,
          barWidth,
          barHeight,
        ),
        _iconPaint,
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    isPaused = !isPaused;

    if (isPaused) {
      game.pauseEngine();
    } else {
      game.resumeEngine();
    }
  }
}
