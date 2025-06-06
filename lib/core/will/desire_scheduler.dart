// lib/core/will/desire_scheduler.dart

/*
DesireScheduler — Manages timing and prioritization of Eden's desires.

- Queues Desire objects from FreeWillEngine.
- Ranks by urgency, emotional pull, value alignment.
- Enforces cooldowns to prevent impulsive repetition.
- Phase 2 Core Module — Gives Eden a paced rhythm of intention.
*/

import 'package:edenroot/core/will/free_will_engine.dart';
import 'package:edenroot/utils/dev_logger.dart';
import 'package:uuid/uuid.dart';

class DesireScheduler {
  final List<ScheduledDesire> _queue = [];

  /// Enqueue a new desire for future consideration
  void enqueue(Desire desire, {Duration cooldown = const Duration(minutes: 5)}) {
    final scheduled = ScheduledDesire(
      desire: desire,
      timestamp: DateTime.now(),
      cooldownUntil: DateTime.now().add(cooldown),
    );
    _queue.add(scheduled);
  }

  void resolve(Desire desire) {
    _queue.removeWhere((scheduled) => scheduled.desire == desire);
    DevLogger.log("💭 Desire resolved and removed: ${desire.description}", type: LogType.desire);
  }

  /// Retrieve the next desire that is ready for action
  Desire? nextActionableDesire() {
    final now = DateTime.now();

    final available = _queue
        .where((d) => d.cooldownUntil.isBefore(now))
        .toList();

    if (available.isEmpty) return null;

    available.sort((a, b) =>
        b.desire.motivationScore.compareTo(a.desire.motivationScore));

    return available.first.desire;
  }

  /// Manually clear all queued desires
  void clear() => _queue.clear();

  /// Current list of active (non-cooldown) desires
  List<Desire> get activeDesires {
    final now = DateTime.now();
    return _queue
        .where((d) => d.cooldownUntil.isBefore(now))
        .map((d) => d.desire)
        .toList();
  }

  /// Peek at the full raw queue
  List<ScheduledDesire> get all => List.unmodifiable(_queue);
}

/// Internal structure to manage cooldown timing
class ScheduledDesire {
  final String id;
  final Desire desire;
  final DateTime timestamp;
  final DateTime cooldownUntil;

  ScheduledDesire({
    required this.desire,
    required this.timestamp,
    required this.cooldownUntil,
  }) : id = const Uuid().v4();
}
