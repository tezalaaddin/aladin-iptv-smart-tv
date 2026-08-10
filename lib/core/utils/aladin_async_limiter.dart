import 'dart:async';
import 'dart:collection';

/// Small FIFO concurrency limiter used by card-level network/database work.
class AladinAsyncLimiter {
  AladinAsyncLimiter(this.maxConcurrent) : assert(maxConcurrent > 0);

  final int maxConcurrent;
  int _running = 0;
  final Queue<Completer<void>> _queue = Queue<Completer<void>>();

  Future<T> run<T>(Future<T> Function() task) async {
    if (_running >= maxConcurrent) {
      final turn = Completer<void>();
      _queue.add(turn);
      await turn.future;
    }
    _running++;
    try {
      return await task();
    } finally {
      _running--;
      if (_queue.isNotEmpty) _queue.removeFirst().complete();
    }
  }
}
