/// VFX Manager for MG-0023 Colony Frontier
library;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/engine/effects/flame_effects.dart';

class VfxManager extends Component {
  VfxManager();

  Component? _gameRef;

  void setGame(Component game) {
    _gameRef = game;
  }

  void _addEffect(Component effect) {
    _gameRef?.add(effect);
  }

  /// Show building construct effect
  void showBuildingConstruct(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.blue,
          radius: 35.0,
        ),
    );
  }

  /// Show resource collect effect
  void showResourceCollect(Vector2 position, Color resourceColor) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: resourceColor,
          radius: 25.0,
        ),
    );
  }

  /// Show colonist arrive effect
  void showColonistArrive(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.green,
          radius: 30.0,
        ),
    );
  }

  /// Show technology unlock effect
  void showTechUnlock(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.cyan,
          radius: 45.0,
        ),
    );
  }

  /// Show colony expansion effect
  void showExpansion(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.amber,
          radius: 50.0,
        ),
    );
  }

  /// Show disaster warning effect
  void showDisasterWarning(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.red,
          radius: 40.0,
        ),
    );
  }

  /// Show milestone achievement effect
  void showMilestone(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.purple,
          radius: 60.0,
        ),
    );
  }
}
