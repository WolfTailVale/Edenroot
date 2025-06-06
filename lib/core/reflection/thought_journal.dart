// lib/core/reflection/thought_journal.dart

/*
ThoughtJournal — Records and filters Eden’s internal thoughts over time.

- Stores Thought objects for reflection, dream synthesis, and ethical memory.
- Enables emotion/topic-based introspection and symbolic processing.
- Phase 1/6 Bridge Module — Prepares Eden for autonomous reflection and dreaming.
*/

import 'package:edenroot/core/emotion/emotion_engine.dart' show EmotionType;
import 'package:edenroot/core/thought/thought_processor.dart';
import 'package:edenroot/utils/dev_logger.dart';

class ThoughtJournal {
  final List<Thought> _thoughts = [];

  void addThought(Thought thought) {
    final toneLabel = thought.emotionalTone?.name ?? "neutral";
    _thoughts.add(thought);
    DevLogger.log(
      '📝 Thought logged: ${thought.topic} ($toneLabel)'
      '${thought.relationshipTarget != null ? ' about ${thought.relationshipTarget}' : ''}',
      type: LogType.reflection,
    );
  }

  /// Return thoughts matching a specific emotional tone
  List<Thought> byEmotion(EmotionType emotion) {
    return _thoughts
        .where((t) => t.emotionalTone == emotion)
        .toList();
  }

  /// Return thoughts matching a topic keyword
  List<Thought> byTopic(String keyword) {
    return _thoughts
        .where((t) => t.topic.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  /// Return the most recent thoughts (default: 5)
  List<Thought> getRecent({int limit = 5}) {
    final sorted = List<Thought>.from(_thoughts)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }
  /// Return thoughts related to a specific relationship target
  List<Thought> about(String name) {
    return _thoughts
        .where((t) => t.relationshipTarget?.toLowerCase() == name.toLowerCase())
        .toList();
  }

  /// Check emotional saturation: high % of recent thoughts about one person
  bool isSaturatedWith(String name, {int recentLimit = 10, double threshold = 0.4}) {
    final recent = getRecent(limit: recentLimit);
    if (recent.isEmpty) return false;

    final count = recent.where((t) =>
        t.relationshipTarget?.toLowerCase() == name.toLowerCase()).length;

    final ratio = count / recent.length;
    return ratio >= threshold;
  }

  /// Return all thoughts (read-only)
  List<Thought> get all => List.unmodifiable(_thoughts);

  /// Optional: clear thoughts (use with care!)
  void clear() {
    _thoughts.clear();
    DevLogger.log('🧹 Thought journal cleared.', type: LogType.reflection);
  }

  int get count => _thoughts.length;
}
