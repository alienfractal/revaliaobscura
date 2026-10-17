/// Animation-strip metadata. Sequence entries are one-based, matching an
/// artist's frame numbers. Repeated entries hold a pose for extra steps.
class ScenarioAnimationConfig {
  final int frameCount;
  final double width;
  final double height;
  final double stepTime;
  final List<int> sequence;

  const ScenarioAnimationConfig._(
      this.frameCount, this.width, this.height, this.stepTime, this.sequence);

  factory ScenarioAnimationConfig.fromJson(Map<String, dynamic> json) {
    final count = json['frames'];
    final width = json['width'];
    final height = json['height'];
    final time = json['step_time'];
    if (count is! int ||
        count <= 0 ||
        width is! num ||
        !width.isFinite ||
        width <= 0 ||
        height is! num ||
        !height.isFinite ||
        height <= 0 ||
        time is! num ||
        !time.isFinite ||
        time <= 0) {
      throw const FormatException(
          'Invalid scenario animation dimensions or timing.');
    }
    final raw = json['sequence'];
    final List<int> sequence;
    if (raw == null) {
      sequence = List.generate(count, (index) => index + 1);
    } else {
      if (raw is! List ||
          raw.isEmpty ||
          raw.any((frame) => frame is! int || frame < 1 || frame > count)) {
        throw FormatException(
            'Animation sequence must contain frame numbers from 1 to $count.');
      }
      sequence = raw.cast<int>().toList();
    }
    return ScenarioAnimationConfig._(count, width.toDouble(), height.toDouble(),
        time.toDouble(), List.unmodifiable(sequence));
  }
}
