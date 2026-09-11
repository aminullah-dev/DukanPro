/// Time. A `Clock` is injected into use cases and domain rules so that
/// time-dependent behaviour is testable at boundary dates. `DateTime.now()`
/// appears only inside [SystemClock]. Store UTC; convert at the UI boundary.
abstract interface class Clock {
  DateTime now();
}

/// Production clock — the only place `DateTime.now()` is permitted.
final class SystemClock implements Clock {
  const SystemClock();
  @override
  DateTime now() => DateTime.now().toUtc();
}

/// For tests. Boundary dates are where time-dependent rules break.
final class FixedClock implements Clock {
  const FixedClock(this._at);
  final DateTime _at;
  @override
  DateTime now() => _at.toUtc();
}
