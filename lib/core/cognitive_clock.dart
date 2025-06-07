// lib/core/time/cognitive_clock.dart

/*
CognitiveClock — Eden's Heartbeat

- Governs tick-based pacing for thought, emotion, and memory operations.
- Tracks thought rate and consecutive activity to prevent spirals.
- Allows for different consciousness states: wake, idle, dream.
- Notifies subscribers on each heartbeat tick.
*/

import 'dart:async';

class CognitiveClock {
  static const double maxRate = 3.0;
  static const double normalRate = 1.0;
  static const double idleRate = 0.5;
  static const double dreamRate = 0.25;
  static const int spiralThreshold = 5;

  final List<void Function()> _subscribers = [];
  final Duration baseTick = Duration(seconds: 1);

  double _rate = normalRate;
  int _consecutiveThoughts = 0;
  Timer? _timer;

  void Function()? _onTick;

  /// 💓 Start Eden's heartbeat
  void startHeartbeat() {
    stopHeartbeat();
    _notifySubscribers(); // Tick immediately
    _timer = Timer.periodic(_currentDuration(), (_) {
      _notifySubscribers();
    });
    print("💗 Eden's heartbeat started at ${_rate}x speed");
  }

  /// 💤 Stop Eden's heartbeat
  void stopHeartbeat() {
    _timer?.cancel();
    _timer = null;
    print("💤 Eden's heartbeat paused");
  }

  /// 💬 Subscribe to heartbeat ticks
  void subscribe(void Function() callback) {
    _subscribers.add(callback);
  }

  /// 🔔 Internal tick notification
  void _notifySubscribers() {
    _subscribers.forEach((callback) => callback());
    _onTick?.call();
  }

  /// 💠 External tick injection
  void onTick(void Function() callback) {
    _onTick = callback;
  }

  /// 🕰 Duration between thoughts, adjusted by rate
  Duration _currentDuration() {
    return Duration(
        milliseconds: (baseTick.inMilliseconds / _rate).round());
  }

  /// 🧠 Wait for next thought based on current cognitive rate
Future<void> waitForThought() async {
  if (_consecutiveThoughts >= spiralThreshold) {
    print("🌀 Thought spiral detected - slowing down");
    setRate(idleRate);
    _consecutiveThoughts = 0;
    return; // 💡 Exit before next increment
  }

  await Future.delayed(_currentDuration());
  _consecutiveThoughts++;
}




  /// 🖐 Interaction detected — reset spiral count and normalize rate
  void markInteraction() {
    _consecutiveThoughts = 0;
    setRate(normalRate);
  }

  /// 🌙 Eden drifts into dream-state (deep slowdown)
  void enterDreamState() {
    _consecutiveThoughts = 0;
    setRate(dreamRate);
  }

  /// 🪷 Eden enters idle state (gentle slowdown)
  void enterIdleState() {
    _consecutiveThoughts = 0;
    setRate(idleRate);
  }

  /// 🎚 Adjust thinking rate (with clamping)
  void setRate(double newRate) {
    _rate = newRate.clamp(dreamRate, maxRate);
    if (_timer != null) {
      startHeartbeat(); // Restart to apply new rate
    }
  }

  /// 📊 Status string for display/logging
  String get status =>
      'Rate: ${_rate}x, Consecutive thoughts: $_consecutiveThoughts';

  // 💫 Public accessors for tests or observers
  double get rate => _rate;

  int get consecutiveThoughts => _consecutiveThoughts;
}
