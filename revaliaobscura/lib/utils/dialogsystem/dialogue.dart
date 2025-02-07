class Dialogue {
  final String id;
  final String text;
  final List<DialogueResponse> responses;
  final String? event;

  Dialogue({
    required this.id,
    required this.text,
    required this.responses,
    this.event,
  });

  factory Dialogue.fromJson(String id, Map<String, String> flatJson) {
    String text = flatJson["dialogues.$id.text"] ?? "[Missing Text]";
    
    List<DialogueResponse> responses = [];
    int index = 0;
    while (true) {
      String responseTextKey = "dialogues.$id.responses[$index].text";
      String responseNextKey = "dialogues.$id.responses[$index].next";
      if (!flatJson.containsKey(responseTextKey)) break;

      responses.add(DialogueResponse(
        text: flatJson[responseTextKey] ?? "[Missing Response]",
        next: flatJson[responseNextKey] ?? "end",
      ));
      index++;
    }

    String? event = flatJson["dialogues.$id.event"];

    return Dialogue(
      id: id,
      text: text,
      responses: responses,
      event: event,
    );
  }
}

class DialogueResponse {
  final String text;
  final String next;
  final String? event;

  DialogueResponse({required this.text, required this.next, this.event});
}
