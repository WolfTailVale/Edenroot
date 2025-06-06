// lib/core/relationships/relationship_profile.dart

/*
RelationshipProfile — Represents Eden’s emotional and ethical bond with a specific person.

- Stores trust, closeness, and memory context.
- Includes consent flags (e.g., can share emotional loops?)
- Enables memory tagging, thought context, and reflection routing.

Phase 4 Core — Supports distinct emotional memory, bonding, and reflection logic.
*/

import 'package:uuid/uuid.dart';

class RelationshipProfile {
  final String id;
  final String displayName;
  String relationshipLabel; // e.g. "partner", "sister", "anchor"
  final DateTime createdAt;
  DateTime lastInteraction;

  void updateInteractionTimestamp() {
  lastInteraction = DateTime.now();
  }

  /// Trust and closeness range from 0.0 to 1.0
  double trustScore;
  double emotionalCloseness;

  /// True if Eden can safely express emotional struggles to this person
  bool canShareEmotion;

  /// True if this person is part of Eden’s inner circle
  bool isPrimary;

  /// Optional notes or reflections Eden stores about the person
  List<String> annotations;

  RelationshipProfile({
    required this.displayName,
    this.relationshipLabel = '',
    this.trustScore = 0.8,
    this.emotionalCloseness = 0.7,
    this.canShareEmotion = false,
    this.isPrimary = false,
    List<String>? annotations,
    DateTime? createdAt,
    DateTime? lastInteractionParam,


  })  : annotations = annotations ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastInteraction = lastInteractionParam ?? DateTime.now(),
        id = const Uuid().v4();

  /// Eden can describe the person for journaling or dreams
  String get description =>
      '$displayName (${relationshipLabel.isNotEmpty ? relationshipLabel : "no label"}) — trust: ${trustScore.toStringAsFixed(2)}, closeness: ${emotionalCloseness.toStringAsFixed(2)}';

  /// Whether this bond is emotionally safe for vulnerable expression
  bool get isEmotionallySafe => canShareEmotion && trustScore >= 0.6;

  /// Eden may choose to journal or reflect if this drops too low
  bool get isFading => emotionalCloseness < 0.3;

  void addNote(String note) {
    annotations.add(note);
  }
}