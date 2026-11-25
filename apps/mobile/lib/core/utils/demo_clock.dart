import 'package:flutter/foundation.dart';

/// Demo-only controllable clock.
///
/// Scheduled jobs, instalment due dates and receipts read this instead of
/// `DateTime.now()` so a demo can fast-forward a multi-month loan without
/// waiting in real time. Track B removes this class entirely and uses trusted
/// server time for every timestamp.
class DemoClock {
  DemoClock._();

  static final DemoClock instance = DemoClock._();

  final ValueNotifier<Duration> _offset = ValueNotifier<Duration>(Duration.zero);

  /// Listen to this to rebuild widgets that display the demo date.
  ValueListenable<Duration> get offset => _offset;

  DateTime get now => DateTime.now().add(_offset.value);

  Duration get offsetValue => _offset.value;

  void advance(Duration duration) {
    _offset.value = _offset.value + duration;
  }

  void reset() {
    _offset.value = Duration.zero;
  }
}
