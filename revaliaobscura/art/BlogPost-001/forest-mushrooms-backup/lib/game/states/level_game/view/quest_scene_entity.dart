import 'package:revalia/game/states/level_game/scenario/scenario_animation_config.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:revalia/game/states/level_game/scenario/scenario_config.dart';
import 'package:revalia/game/states/level_game/behaviours/look_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/grab_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/talk_action_behaviour.dart';
import 'package:revalia/game/states/level_game/view/entity_tap_behaviour.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

/// JSON-defined art slots. Missing art is explicitly represented by a labelled
/// block; replacing the asset path needs no interaction-code changes.
class QuestSceneEntity extends LevelEntity {
  final ScenarioEntityConfig config;
  QuestSceneEntity(this.config)
      : super(
            position: config.feetPosition - Vector2(0, config.size.y / 2),
            size: config.size.clone(),
            interactionId: config.interactionId,
            dialogueActorId: config.dialogueActorId,
            behaviors: config.type == 'decoration' ? [] : [
              LookActionBehaviour(),
              GrabActionBehaviour(),
              TalkActionBehaviour(),
              EntityTapBehaviour()
            ]);

  @override
  bool get usesPerspectiveScaling =>
      !config.assetId.startsWith('placeholder:') &&
      config.scalesWithPerspective;
  @override
  bool get usesDepthSorting => config.sortsWithDepth;

  @override
  void update(double dt) {
    super.update(dt);
    final motion = config.motion;
    if (motion == null) return;
    final from = (motion['from_x'] as num).toDouble();
    final to = (motion['to_x'] as num).toDouble();
    final speed = (motion['speed'] as num).toDouble();
    // Keep overshoot so playback stays smooth at different frame rates.
    // Both endpoints are outside the VIEW, hiding the wraparound.
    position.x = from + (position.x - from + speed * dt) % (to - from);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (config.assetId.startsWith('placeholder:')) {
      // Deliberately simple temporary markers, not replacement character art.
      add(RectangleComponent(
          size: size.clone(), paint: Paint()..color = const Color(0xdd342f42)));
      add(TextComponent(
          text: game.gboard.adventureText('scene.${config.interactionId}'),
          position: size / 2,
          anchor: Anchor.center,
          textRenderer: TextPaint(
              style: const TextStyle(
                  fontFamily: 'scumm',
                  fontSize: 7,
                  color: Color(0xffffdb69)))));
      // LevelEntity's idle handling still expects an animation component.
      final sprite = await game.loadSprite('resources/images/walking_area.png');
      animationHandler.init(
          idleAnimation: SpriteAnimation.spriteList([sprite], stepTime: 1),
          size: Vector2.zero(),
          parent: this);
      return;
    }
    final idle = await _animation(config.assetId, config.animation);
    final talk = config.talkAsset == null
        ? null
        : await _animation(config.talkAsset!, config.talkAnimation);
    animationHandler.init(
        idleAnimation: idle, talkAnimation: talk, size: size, parent: this);
  }

  Future<SpriteAnimation> _animation(
      String asset, Map<String, dynamic>? spec) async {
    if (spec == null) {
      return SpriteAnimation.spriteList([await game.loadSprite(asset)],
          stepTime: 1);
    }
    final config = ScenarioAnimationConfig.fromJson(spec);
    return game.loadSpriteAnimation(
        asset,
        SpriteAnimationData([
          for (final frame in config.sequence)
            SpriteAnimationFrameData(
              srcPosition: Vector2((frame - 1) * config.width, 0),
              srcSize: Vector2(config.width, config.height),
              stepTime: config.stepTime,
            ),
        ], loop: true));
  }

  @override
  bool shouldApproachFor(
          ActionableType actionType) =>
      config.destination != null &&
              (actionType == ActionableType.move ||
                  actionType == ActionableType.touch)
          ? true
          : super.shouldApproachFor(actionType);

  @override
  void performAction(ActionableType actionType) {
    if (config.destination != null &&
        (actionType == ActionableType.move ||
            actionType == ActionableType.touch)) {
      game.gboard.travelTo(config.destination!);
      return;
    }
    super.performAction(actionType);
  }
}
