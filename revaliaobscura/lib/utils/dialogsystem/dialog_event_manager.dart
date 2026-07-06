enum DialogEvent { start, end, active }

class DialogEventManager {
  /// Simply logs the event.
  static void notifycation({required String event}) {
    print("Event triggered: $event");
  }
}
