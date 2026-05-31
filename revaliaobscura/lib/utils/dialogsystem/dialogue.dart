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
  }) {
    final responses = <DialogueResponse>[];
    final graphResponses = graphNode['responses'] as List<dynamic>? ?? [];
    for (var index = 0; index < graphResponses.length; index++) {
      final graphResponse = graphResponses[index] as Map<String, dynamic>;
      responses.add(
        DialogueResponse(
          text: translations['dialogues.$id.responses[$index].text'] ??
              '[Missing Response: $id[$index]]',
          next: graphResponse['next'] as String? ?? 'end',
          event: graphResponse['event'] as String?,
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
  final String text;
  final String next;
  final String? event;

  DialogueResponse({required this.text, required this.next, this.event});
}
