class EventListener<T> {
  List<T> receivedEvents;

  EventListener() {
    this.receivedEvents = [];
  }

  void receive(T event) {
    this.receivedEvents.add(event);
  }

  int occurences(T event) => this.receivedEvents.where((element) => element == event).length;
}
