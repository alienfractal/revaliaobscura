class Dialogue {
  final String id;
  final String text;
  final String playerText;
  final List<DialogueResponse> responses;
  final String? event;

  Dialogue({
    required this.id,
    required this.text,
    required this.playerText,
    required this.responses,
    this.event,
  });

  factory Dialogue.fromGraph({
    required String id,
    required Map<String, dynamic> graphNode,
    required Map<String, String> translations,
    required bool Function(
      String responseId,
      Map<String, dynamic>? condition,
      bool once,
    ) isResponseAvailable,
  }) {
    final responses = <DialogueResponse>[];
    final graphResponses = graphNode['responses'] as List<dynamic>? ?? [];
    for (final responseData in graphResponses) {
      final graphResponse = responseData as Map<String, dynamic>;
      final responseId = graphResponse['id'] as String;
      final condition = graphResponse['when'] as Map<String, dynamic>?;
      final once = graphResponse['once'] as bool? ?? false;
      if (!isResponseAvailable(responseId, condition, once)) {
        continue;
      }
      responses.add(
        DialogueResponse(
          id: responseId,
          text: translations['dialogues.$id.responses.$responseId.text'] ??
              '[Missing Response: $id.$responseId]',
          next: graphResponse['next'] as String? ?? 'end',
          event: graphResponse['event'] as String?,
          effects: (graphResponse['effects'] as List<dynamic>? ?? [])
              .map((effect) => effect as Map<String, dynamic>)
              .toList(),
          once: once,
        ),
      );
    }

    return Dialogue(
      id: id,
      text: translations['dialogues.$id.text'] ?? '[Missing Text: $id]',
      playerText: translations['dialogues.$id.player_text'] ??
          '[Missing Player Text: $id]',
      responses: responses,
      event: graphNode['event'] as String?,
    );
  }
}

class DialogueResponse {
  final String id;
  final String text;
  final String next;
  final String? event;
  final List<Map<String, dynamic>> effects;
  final bool once;

  DialogueResponse({
    required this.id,
    required this.text,
    required this.next,
    required this.effects,
    required this.once,
    this.event,
  });
}
