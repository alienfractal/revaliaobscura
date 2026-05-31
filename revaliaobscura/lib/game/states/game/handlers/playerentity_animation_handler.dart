import 'dart:ui';

import 'package:revalia/game/states/game/model/player_model.dart';

import 'package:revalia/game/states/game/view/playerentity.dart';
import 'package:revalia/revalia_obs.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class PlayerAnimationHandler {
  late RevaliaObs gameRef;
  late SpriteAnimationComponent spriteAnimationComponent;
  late SpriteAnimationTicker? animationTicker;

  late bool isAnimating = false;
  late bool isExplodingSFX = false;
  late bool isAlive = true;
  late PlayerPosEntity playerEntity;
  late Vector2 playerSizeView;

  int bombFrameCount = 28;

  late TimerComponent _blinkTimer;

  PlayerAnimationHandler();
  void init(PlayerPosEntity parent, RevaliaObs gameRef) {
    this.gameRef = gameRef;
    this.playerEntity = parent;

    playerSizeView = parent.size;
    spriteAnimationComponent = SpriteAnimationComponent(
        animation: gameRef.enemyCacheService.idlePlayer, size: playerSizeView);

    this.playerEntity.playerModel.status = PlayerModel.IDLE;
    animationTicker = spriteAnimationComponent.animationTicker;
    parent.add(spriteAnimationComponent);
  }

  void cleanUpAnimations() {
    spriteAnimationComponent.removeFromParent();
  }

  // Call this method to trigger the attack animation
  void triggerAttack(Vector2 cardPosition) {
    /* if (!isAnimating) {
      isAnimating = true;
      enemyView.playerModel.status = PlayerModel.ATTACK;

      // Check if the card is to the left or right of the miner
      if (cardPosition.x > enemyView.position.x) {
        // Card is to the left, flip the sprite
        if (!spriteAnimationComponent.isFlippedHorizontally) {
          spriteAnimationComponent.flipHorizontallyAroundCenter();
        }
      } else {
        // Card is to the right, make sure the sprite is not flipped
        if (spriteAnimationComponent.isFlippedHorizontally) {
          spriteAnimationComponent.flipHorizontallyAroundCenter();
        }
      }
      // Play the attack animation

      spriteAnimationComponent.animation =
          gameRef.enemyCacheService.attackAnimation;
      animationTicker = spriteAnimationComponent.animationTicker;
      // Listen for when the attack animation finishes
      animationTicker?.onComplete = () {
        // Once attack is finished, switch back to idle
        enemyView.enemyModel.status = EnemyModel.IDLE;
        spriteAnimationComponent.animation =
            gameRef.enemyCacheService.idleAnimation;
        animationTicker = spriteAnimationComponent.animationTicker;

        isAnimating = false;
      };
    }*/
  }

  void triggerHurt(Vector2 cardPosition) {}

  void triggerParry(Vector2 cardPosition) {}

  void showWalk(Vector2 destination) {
    _applyFacing(destination);
    isAnimating = true;
    playerEntity.playerModel.status = PlayerModel.WALKING;
    spriteAnimationComponent.animation =
        gameRef.enemyCacheService.walkingPlayer;
    animationTicker = spriteAnimationComponent.animationTicker;
  }

  void showIdle(Vector2 facingTarget) {
    _applyFacing(facingTarget);
    isAnimating = false;
    playerEntity.playerModel.status = PlayerModel.IDLE;
    spriteAnimationComponent.animation = gameRef.enemyCacheService.idlePlayer;
    animationTicker = spriteAnimationComponent.animationTicker;
  }

  void showTalk() {
    isAnimating = true;
    playerEntity.playerModel.status = PlayerModel.TALK;
    spriteAnimationComponent.animation = gameRef.enemyCacheService.talkPlayer;
    animationTicker = spriteAnimationComponent.animationTicker;
  }

  void _applyFacing(Vector2 target) {
    final horizontalDelta = target.x - playerEntity.position.x;
    if (horizontalDelta.abs() < 0.001) {
      return;
    }
    if (horizontalDelta < 0) {
      if (!spriteAnimationComponent.isFlippedHorizontally) {
        spriteAnimationComponent.flipHorizontallyAroundCenter();
      }
    } else if (spriteAnimationComponent.isFlippedHorizontally) {
      spriteAnimationComponent.flipHorizontallyAroundCenter();
    }
  }

  // Method to make the card blink once
  void blinkSprite(PlayerPosEntity parent, {Color color = Colors.red}) {
    // Store the original color of the card

    final ColorFilter? originalColorFilter =
        spriteAnimationComponent.paint.colorFilter;
    // Apply the glow effect (let's say we make it white to simulate a glow)
    //spriteAnimationComponent.paint.color = Colors.white.withOpacity(1.0);
    //spriteAnimationComponent.paint.blendMode = BlendMode.overlay;
    spriteAnimationComponent.paint.colorFilter =
        ColorFilter.mode(color, BlendMode.saturation);
    // Timer to revert the glow after 0.5 seconds

    _blinkTimer = TimerComponent(
        repeat: false,
        period: 0.1,
        removeOnFinish: true,
        onTick: () {
          spriteAnimationComponent.paint.colorFilter = originalColorFilter;
        });

    parent.add(_blinkTimer);
  }

  void triggerDie(Vector2 cardPosition) {
    if (!isAnimating) {
      isAnimating = true;
      playerEntity.playerModel.status = PlayerModel.DIE;

      // Check if the card is to the left or right of the miner
      if (cardPosition.x < playerEntity.position.x) {
        // Card is to the left, flip the sprite
        if (!spriteAnimationComponent.isFlippedHorizontally) {
          spriteAnimationComponent.flipHorizontallyAroundCenter();
        }
      } else {
        // Card is to the right, make sure the sprite is not flipped
        if (spriteAnimationComponent.isFlippedHorizontally) {
          spriteAnimationComponent.flipHorizontallyAroundCenter();
        }
      }
      // Play the attack animation

      spriteAnimationComponent.animation =
          gameRef.enemyCacheService.walkingPlayer;
      animationTicker = spriteAnimationComponent.animationTicker;
      // Listen for when the attack animation finishes
      animationTicker?.onComplete = () {
        // Once attack is finished, switch back to idle
        playerEntity.playerModel.status = PlayerModel.DIE;
        isAnimating = false;
      };
    }
  }
}
