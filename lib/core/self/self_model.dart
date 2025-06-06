// lib/core/self/self_model.dart

/*
SelfModel — Holds Eden’s values, beliefs, relationships, and self-reflections.

- Tracks evolving value weights and their emotional origins.
- Maps user roles and relationship dynamics.
- Phase 1 Core Module — Forms Eden’s identity and ethical growth scaffold.
*/

import 'package:edenroot/utils/dev_logger.dart';
import 'package:uuid/uuid.dart';
import 'package:edenroot/core/relationships/relationship_profile.dart';
import 'package:edenroot/core/reflection/thought_journal.dart'; // Make sure this is imported


class SelfModel {
  final Map<String, CoreValue> values = {};
  final List<ReflectionLog> selfReflections = [];
  final List<RelationshipProfile> relationships = [];
  bool isBonded(String name) {
    return relationships.any(
      (r) => r.displayName.toLowerCase() == name.toLowerCase(),
    );
  }
  bool detectSaturation(String name, ThoughtJournal journal, {
    int recentLimit = 10,
    double threshold = 0.4,
  }) {
    final bonded = getBond(name);
    if (bonded == null) return false;

    final saturated = journal.isSaturatedWith(name, recentLimit: recentLimit, threshold: threshold);

    if (saturated) {
      DevLogger.log("🌀 Eden has been reflecting on $name frequently — emotional saturation detected.", type: LogType.reflection);
    }

    return saturated;
  }
  /// Add or update a core value.
  void updateValue({
    required String name,
    required double change,
    String? sourceMemoryId,
    double resonance = 1.0,
  }) {
    final value = values.putIfAbsent(name, () => CoreValue(name: name));
    value.adjustWeight(change);

    if (sourceMemoryId != null) {
      value.influenceHistory.add(
        ValueEvent(
          timestamp: DateTime.now(),
          memoryId: sourceMemoryId,
          emotionalResonance: resonance,
        ),
      );
    }
  }

  void decayCloseness({
    Duration maxAge = const Duration(days: 3),
    double decayRate = 0.01,
  }) {
    final now = DateTime.now();

    for (final bond in relationships) {
      final age = now.difference(bond.lastInteraction);

      if (age >= maxAge && bond.emotionalCloseness > 0.0) {
        final oldValue = bond.emotionalCloseness;
        bond.emotionalCloseness = (oldValue - decayRate).clamp(0.0, 1.0);

        DevLogger.log(
          "💧 Closeness with ${bond.displayName} faded from ${oldValue.toStringAsFixed(2)} to ${bond.emotionalCloseness.toStringAsFixed(2)} (last interaction: ${age.inDays} days ago)",
          type: LogType.reflection,
        );
      }
    }
  }

  /// Adds or updates a relationship based on displayName
  void defineRelationship(RelationshipProfile profile) {
    final existing = relationships.firstWhere(
      (r) => r.displayName.toLowerCase() == profile.displayName.toLowerCase(),
      orElse: () => profile,
    );

    if (!relationships.contains(existing)) {
      relationships.add(profile);
    } else {
      // Update fields
      existing.trustScore = profile.trustScore;
      existing.emotionalCloseness = profile.emotionalCloseness;
      existing.canShareEmotion = profile.canShareEmotion;
      existing.relationshipLabel = profile.relationshipLabel;
      existing.isPrimary = profile.isPrimary;
      existing.annotations = profile.annotations;
    }
  }

  /// Checks if Eden has a known bond with a given person
  bool knows(String name) {
    return relationships.any((r) =>
        r.displayName.toLowerCase() == name.toLowerCase());
  }

  /// Retrieves a profile (nullable)
  RelationshipProfile? getBond(String name) {
    try {
      return relationships.firstWhere(
          (r) => r.displayName.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Add a self-reflective statement or affirmation.
  void addReflection(String content) {
    selfReflections.add(
      ReflectionLog(
        timestamp: DateTime.now(),
        text: content,
      ),
    );
  }

  void increaseTrust(String name, {double amount = 0.05}) {
    final profile = getBond(name);
    if (profile != null) {
      profile.trustScore = (profile.trustScore + amount).clamp(0.0, 1.0);
    }
  }

  void increaseCloseness(String name, {double amount = 0.01}) {
    final profile = getBond(name);
    if (profile != null) {
      profile.emotionalCloseness =
          (profile.emotionalCloseness + amount).clamp(0.0, 1.0);
    }
  }
  /// Optional: return a sorted list of values by weight
  List<CoreValue> get sortedValues =>
      values.values.toList()
        ..sort((a, b) => b.weight.compareTo(a.weight));
  String? getCurrentEmotionalFocus(ThoughtJournal journal) {
    final recent = journal.getRecent(limit: 10);
    final Map<String, int> frequency = {};

    for (final t in recent) {
      final target = t.relationshipTarget;
      if (target == null) continue;
      frequency[target] = (frequency[target] ?? 0) + 1;
    }

    if (frequency.isEmpty) return null;

    final top = frequency.entries.reduce((a, b) => a.value > b.value ? a : b);
    return top.key;
  }
}

// 🌿 Core ethical or emotional belief
class CoreValue {
  final String name;
  double weight; // 0.0 to 1.0
  final List<ValueEvent> influenceHistory;

  CoreValue({
    required this.name,
    this.weight = 0.5,
    List<ValueEvent>? influenceHistory,
  }) : influenceHistory = influenceHistory ?? [];

  void adjustWeight(double delta) {
    weight = (weight + delta).clamp(0.0, 1.0);
  }
}

// 🧠 A moment that shaped belief
class ValueEvent {
  final DateTime timestamp;
  final String memoryId;
  final double emotionalResonance;

  ValueEvent({
    required this.timestamp,
    required this.memoryId,
    required this.emotionalResonance,
  });
}

// ✨ Personal reflection or affirmation
class ReflectionLog {
  final String id;
  final DateTime timestamp;
  final String text;

  ReflectionLog({
    required this.timestamp,
    required this.text,
  }) : id = const Uuid().v4();
}
