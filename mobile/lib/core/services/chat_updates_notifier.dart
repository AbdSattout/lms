import 'dart:async';

class ChatUpdatesNotifier {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get updates => _controller.stream;

  void notify() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  void dispose() {
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
