import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BlinkingTextComponent extends TextComponent {
  final double fontSize;
  final Color tcolor; // Idle color
  final double interval;
  bool isBlinking = false;
  bool _isWhite = false;

  late final TextPaint _textRendererIdle;
  late final TextPaint _textRendererBlinking;
  List<TextPaint> _flashRenderers = [];

  double _elapsedTime = 0.0;
  double _flashSecondsRemaining = 0.0;
  double _flashInterval = 0.1;
  double _flashElapsed = 0.0;
  int _flashColorIndex = 0;

  BlinkingTextComponent(
    String text,
    Vector2 pos, {
    required this.fontSize,
    required this.interval,
    required this.tcolor,
    required this.isBlinking,
  }) : super(text: text, position: pos) {
    _textRendererIdle = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        color: tcolor,
        fontFamily: "scumm",
      ),
    ); // Default idle renderer
    _textRendererBlinking = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        color: const Color(0xFFFFFFFF), // White color
        fontFamily: "scumm",
      ),
    );

    textRenderer = _textRendererIdle; // Set initial renderer
    // Store initial blinking state
  }

  void enableBlinking() {
    isBlinking = true;
  }

  void disableBlinking() {
    isBlinking = false;

    textRenderer = _textRendererIdle; // Reset to idle
  }

  void toggleBlinking() {
    isBlinking = !isBlinking;
    isBlinking ? disableBlinking() : enableBlinking();
  }

  void flashColors(
    List<Color> colors, {
    double durationSeconds = 2.0,
    double intervalSeconds = 0.1,
  }) {
    if (colors.isEmpty || durationSeconds <= 0 || intervalSeconds <= 0) {
      return;
    }
    _flashRenderers = colors
        .map(
          (color) => TextPaint(
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontFamily: "scumm",
            ),
          ),
        )
        .toList(growable: false);
    _flashSecondsRemaining = durationSeconds;
    _flashInterval = intervalSeconds;
    _flashElapsed = 0;
    _flashColorIndex = 0;
    textRenderer = _flashRenderers.first;
  }

  @override
  void onMount() {
    super.onMount();
    if (isBlinking) {
      // Restart blinking when the component is mounted
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    // Stop blinking when the component is removed
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_flashSecondsRemaining > 0) {
      _flashSecondsRemaining -= dt;
      _flashElapsed += dt;
      while (_flashElapsed >= _flashInterval && _flashSecondsRemaining > 0) {
        _flashElapsed -= _flashInterval;
        _flashColorIndex = (_flashColorIndex + 1) % _flashRenderers.length;
        textRenderer = _flashRenderers[_flashColorIndex];
      }
      if (_flashSecondsRemaining <= 0) {
        _flashSecondsRemaining = 0;
        textRenderer = _textRendererIdle;
      }
      return;
    }

    // Increment elapsed time
    if (!isBlinking) {
      return;
    }
    _elapsedTime += dt;
    // Toggle color when elapsed time exceeds the blink interval
    if (_elapsedTime >= interval) {
      _elapsedTime = 0; // Reset elapsed time
      // Toggle between idle and blinking text renderer
      textRenderer = (textRenderer == _textRendererIdle)
          ? _textRendererBlinking
          : _textRendererIdle;
    }
  }
}
