/// VFX Manager for MG-0023 Colony Frontier
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
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.blue,
        particleCount: 20,
        duration: 0.6,
        spreadRadius: 35.0,
      ),
    );
  }

  /// Show resource collect effect
  void showResourceCollect(Vector2 position, Color resourceColor) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: resourceColor,
        particleCount: 12,
        duration: 0.4,
        spreadRadius: 25.0,
      ),
    );
  }

  /// Show colonist arrive effect
  void showColonistArrive(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.green,
        particleCount: 15,
        duration: 0.5,
        spreadRadius: 30.0,
      ),
    );
  }

  /// Show technology unlock effect
  void showTechUnlock(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.cyan,
        particleCount: 25,
        duration: 0.7,
        spreadRadius: 45.0,
      ),
    );
  }

  /// Show colony expansion effect
  void showExpansion(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.amber,
        particleCount: 30,
        duration: 0.8,
        spreadRadius: 50.0,
      ),
    );
  }

  /// Show disaster warning effect
  void showDisasterWarning(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.red,
        particleCount: 20,
        duration: 0.5,
        spreadRadius: 40.0,
      ),
    );
  }

  /// Show milestone achievement effect
  void showMilestone(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.purple,
        particleCount: 40,
        duration: 1.0,
        spreadRadius: 60.0,
      ),
    );
  }
}
