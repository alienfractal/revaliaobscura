enum DialogEvent { start, end, active }

typedef DialogueEventListener = void Function(String event);

class DialogEventManager {
  static final Set<DialogueEventListener> _listeners = {};

  static void addListener(DialogueEventListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(DialogueEventListener listener) {
    _listeners.remove(listener);
  }

  static void notifycation({required String event}) {
    print("Event triggered: $event");
    for (final listener in List<DialogueEventListener>.of(_listeners)) {
      listener(event);
    }
  }
}
