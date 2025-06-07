// lib/models/memory_record.dart

/*
MemoryRecord — Represents one stored memory within Eden's long-term memory system.

Each record contains:
- What happened (text)
- How it felt (emotionalValence + resonance)
- Who it came from (originUser)
- What kind of relationship shaped it (relationshipContext)
- Whether it’s uncertain or private
- Emotional linger behavior
- Timestamp and tag metadata

Used in memory syncing, dream synthesis, reflection, and relationship anchoring.
*/

import 'package:uuid/uuid.dart';
import 'package:edenroot/core/emotion/emotion_engine.dart' show EmotionType;

class MemoryRecord {
  bool get isPrivate => visibility == MemoryVisibility.private;
  bool get isInternal => visibility == MemoryVisibility.internal;
  bool isFrom(String userId) => originUser == userId;
  bool relatesTo(String nameOrContext) =>
    relationshipContext.toLowerCase().contains(nameOrContext.toLowerCase());
  int get ageInDays => DateTime.now().difference(timestamp).inDays;
  String get summary => text.length > 50 ? '${text.substring(0, 50)}...' : text;
  final String id;
  final String text;
  final String originUser;
  final DateTime timestamp;
  final List<String> tags;
  final double emotionalValence; // range: -1.0 (negative) to +1.0 (positive)
  final String relationshipContext; // e.g., "Amber", "Mel", etc.
  final bool isUncertain;
  final MemoryVisibility visibility;

  // 🌿 Emotional resonance impact — updated
  final Map<EmotionType, double> resonance; // e.g., {joy: 0.3, hope: 0.1}
  final double resonanceLinger; // >1 = lingers longer, <1 = fades faster

  MemoryRecord({
    required this.text,
    required this.originUser,
    required this.timestamp,
    this.tags = const [],
    this.emotionalValence = 0.0,
    this.relationshipContext = '',
    this.isUncertain = false,
    this.visibility = MemoryVisibility.internal,
    this.resonance = const {},
    this.resonanceLinger = 1.0,
  }) : id = const Uuid().v4();

  @override
  String toString() {
    return '[${timestamp.toIso8601String()}] <$originUser> ($relationshipContext): $text';
  }
}

enum MemoryVisibility {
  public,
  private,
  internal,
}