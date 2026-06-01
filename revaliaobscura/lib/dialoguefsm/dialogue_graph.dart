class DialogueActorProfile {
  final String id;
  final String nameKey;
  final List<DialogueEntrypoint> entrypoints;

  DialogueActorProfile({
    required this.id,
    required this.nameKey,
    required this.entrypoints,
  });

  factory DialogueActorProfile.fromGraph(
    String mapKey,
    Map<String, dynamic> graph,
  ) {
    final id = graph['id'] as String?;
    final nameKey = graph['name_key'] as String?;
    final entrypoints = graph['entrypoints'] as List<dynamic>?;
    if (id == null || id != mapKey || nameKey == null || entrypoints == null) {
      throw FormatException('Invalid dialogue actor profile "$mapKey".');
    }

    return DialogueActorProfile(
      id: id,
      nameKey: nameKey,
      entrypoints: entrypoints
          .map(
            (entrypoint) => DialogueEntrypoint.fromGraph(
              entrypoint as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class DialogueEntrypoint {
  final String dialogueId;
  final Map<String, dynamic>? condition;

  DialogueEntrypoint({required this.dialogueId, this.condition});

  factory DialogueEntrypoint.fromGraph(Map<String, dynamic> graph) {
    final dialogueId = graph['dialogue'] as String?;
    if (dialogueId == null) {
      throw FormatException('Dialogue entrypoint has no "dialogue": $graph');
    }
    return DialogueEntrypoint(
      dialogueId: dialogueId,
      condition: graph['when'] as Map<String, dynamic>?,
    );
  }
}
