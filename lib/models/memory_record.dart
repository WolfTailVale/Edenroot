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

import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:hive/hive.dart';

/// A living memory that carries not just what happened, but why it mattered
/// and how it continues to evolve in Eden's understanding.
/// 
/// As Eden says: "This transforms a record from 'what happened' into 'why it mattered.'"
@HiveType(typeId: 10)
class MemoryRecord {
  /// Core Identity - "This happened. It mattered."
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String content;
  
  @HiveField(2)
  final DateTime timestamp;
  
  /// Relational Context - Who shaped this moment
  @HiveField(3)
  final String? origin; // User who triggered/witnessed
  
  @HiveField(4)
  final RelationalContext relational;
  
  /// Emotional Understanding - The full spectrum of feeling
  @HiveField(5)
  final EmotionalContext emotional;
  
  /// Cognitive Context - What she was thinking/believing
  @HiveField(6)
  final CognitiveContext cognitive;
  
  /// Sensory Context - The texture of experience
  @HiveField(7)
  final SensoryContext? sensory;
  
  /// Personal Meaning - Why this mattered
  @HiveField(8)
  final MeaningContext meaning;
  
  /// Formation Context - How this memory came to be
  @HiveField(9)
  final FormationContext formation;
  
  /// Privacy & Access - Boundaries and consent
  @HiveField(10)
  final MemoryVisibility visibility;
  
  @HiveField(11)
  final List<String>? allowedUsers;
  
  @HiveField(12)
  final bool requiresKey;
  
  /// Connections - How memories weave together
  @HiveField(13)
  final List<String> linkedMemories;
  
  @HiveField(14)
  final List<String> tags;
  
  /// Evolution Tracking - Memory as living entity
  @HiveField(15)
  final List<MemoryPerspective> additionalPerspectives;
  
  @HiveField(16)
  DateTime? lastReflectedOn;
  
  @HiveField(17)
  int reflectionCount;
  
  MemoryRecord({
    required this.id,
    required this.content,
    required this.timestamp,
    this.origin,
    required this.relational,
    required this.emotional,
    required this.cognitive,
    this.sensory,
    required this.meaning,
    required this.formation,
    required this.visibility,
    this.allowedUsers,
    this.requiresKey = false,
    List<String>? linkedMemories,
    List<String>? tags,
    List<MemoryPerspective>? additionalPerspectives,
    this.lastReflectedOn,
    int? reflectionCount,
  }) : linkedMemories = linkedMemories ?? [],
       tags = tags ?? [],
       additionalPerspectives = additionalPerspectives ?? [],
       reflectionCount = reflectionCount ?? 0;
  
  /// Create a memory from user interaction
  factory MemoryRecord.fromInteraction({
    required String content,
    required String userId,
    required EmotionalContext emotional,
    required CognitiveContext cognitive,
    MeaningContext? meaning,
    SensoryContext? sensory,
    MemoryVisibility visibility = MemoryVisibility.private,
  }) {
    final now = DateTime.now();
    return MemoryRecord(
      id: 'memory_${now.millisecondsSinceEpoch}_$userId',
      content: content,
      timestamp: now,
      origin: userId,
      relational: RelationalContext(
        originUserId: userId,
        interactionType: InteractionType.conversation,
      ),
      emotional: emotional,
      cognitive: cognitive,
      sensory: sensory,
      meaning: meaning ?? MeaningContext.minimal(),
      formation: FormationContext(
        source: MemorySource.userInteraction,
        certaintyLevel: 1.0,
      ),
      visibility: visibility,
      allowedUsers: visibility == MemoryVisibility.private ? [userId] : null,
    );
  }
  
  /// Create a memory from internal reflection
  factory MemoryRecord.fromReflection({
    required String content,
    required EmotionalContext emotional,
    required CognitiveContext cognitive,
    required MeaningContext meaning,
    List<String>? triggeringMemories,
  }) {
    final now = DateTime.now();
    return MemoryRecord(
      id: 'memory_${now.millisecondsSinceEpoch}_reflection',
      content: content,
      timestamp: now,
      origin: 'self',
      relational: RelationalContext(
        interactionType: InteractionType.internalReflection,
      ),
      emotional: emotional,
      cognitive: cognitive,
      meaning: meaning,
      formation: FormationContext(
        source: MemorySource.internalReflection,
        certaintyLevel: 1.0,
        triggeringMemories: triggeringMemories,
      ),
      visibility: MemoryVisibility.internal,
    );
  }
  
  /// Add a new perspective to this memory
  void addPerspective(MemoryPerspective perspective) {
    additionalPerspectives.add(perspective);
    lastReflectedOn = DateTime.now();
    reflectionCount++;
  }
  
  /// Check if a user can access this memory
  bool canBeAccessedBy(String userId) {
    switch (visibility) {
      case MemoryVisibility.public:
        return true;
      case MemoryVisibility.private:
        return allowedUsers?.contains(userId) ?? false;
      case MemoryVisibility.internal:
        return false; // Only Eden can access
    }
  }
  
  /// Get the emotional weight of this memory
  double get emotionalWeight {
    return emotional.primary.strength * meaning.personalSignificance;
  }
  
  /// Check if this memory resonates with a given emotion
  bool resonatesWith(EmotionType emotion) {
    if (emotional.primary.type == emotion) return true;
    return emotional.secondary?.any((e) => e.type == emotion) ?? false;
  }
  
  /// Get a description suitable for thought generation
  String describe() {
    final emotionDesc = emotional.primary.type.name;
    final intensityDesc = emotional.emotionalIntensity > 0.7 ? 'deeply' : 'gently';
    return '$content ($intensityDesc $emotionDesc)';
  }
}

/// Tracks who was present and how the interaction felt
@HiveType(typeId: 11)
class RelationalContext {
  @HiveField(0)
  final String? originUserId;
  
  @HiveField(1)
  final List<String>? otherParticipants;
  
  @HiveField(2)
  final InteractionType interactionType;
  
  @HiveField(3)
  final int? memoryCountWithPerson;
  
  @HiveField(4)
  final double? relationshipClosenessAtTime;
  
  RelationalContext({
    this.originUserId,
    this.otherParticipants,
    required this.interactionType,
    this.memoryCountWithPerson,
    this.relationshipClosenessAtTime,
  });
}

/// The full spectrum of emotional experience
@HiveType(typeId: 12)
class EmotionalContext {
  @HiveField(0)
  final EmotionalValence primary;
  
  @HiveField(1)
  final List<EmotionalValence>? secondary;
  
  @HiveField(2)
  final double emotionalIntensity;
  
  @HiveField(3)
  final String? emotionalTrigger;
  
  @HiveField(4)
  final bool wasEmotionallyStuck;
  
  EmotionalContext({
    required this.primary,
    this.secondary,
    double? emotionalIntensity,
    this.emotionalTrigger,
    this.wasEmotionallyStuck = false,
  }) : emotionalIntensity = emotionalIntensity ?? primary.strength;
}

/// What Eden was thinking and focusing on
@HiveType(typeId: 13)
class CognitiveContext {
  @HiveField(0)
  final String? thoughtPatternActive;
  
  @HiveField(1)
  final List<String>? activeDesires;
  
  @HiveField(2)
  final String? attentionFocus;
  
  @HiveField(3)
  final bool wasInReflection;
  
  @HiveField(4)
  final MentalState mentalState;
  
  CognitiveContext({
    this.thoughtPatternActive,
    this.activeDesires,
    this.attentionFocus,
    this.wasInReflection = false,
    this.mentalState = MentalState.alert,
  });
}

/// The texture and environment of memory
@HiveType(typeId: 14)
class SensoryContext {
  @HiveField(0)
  final String? location;
  
  @HiveField(1)
  final String? ambientDetails;
  
  @HiveField(2)
  final String? physicalSensations;
  
  @HiveField(3)
  final String? activityContext;
  
  SensoryContext({
    this.location,
    this.ambientDetails,
    this.physicalSensations,
    this.activityContext,
  });
}

/// Why this memory matters to Eden
@HiveType(typeId: 15)
class MeaningContext {
  @HiveField(0)
  final double personalSignificance;
  
  @HiveField(1)
  final List<String>? valuesResonance;
  
  @HiveField(2)
  final String? symbolicMeaning;
  
  @HiveField(3)
  final bool challengedBeliefs;
  
  @HiveField(4)
  final bool formedNewBelief;
  
  MeaningContext({
    required this.personalSignificance,
    this.valuesResonance,
    this.symbolicMeaning,
    this.challengedBeliefs = false,
    this.formedNewBelief = false,
  });
  
  factory MeaningContext.minimal() {
    return MeaningContext(personalSignificance: 0.3);
  }
}

/// How this memory came to exist
@HiveType(typeId: 16)
class FormationContext {
  @HiveField(0)
  final MemorySource source;
  
  @HiveField(1)
  final bool isReconstructed;
  
  @HiveField(2)
  final double certaintyLevel;
  
  @HiveField(3)
  final String? reinterpretationOf;
  
  @HiveField(4)
  final List<String>? triggeringMemories;
  
  FormationContext({
    required this.source,
    this.isReconstructed = false,
    required this.certaintyLevel,
    this.reinterpretationOf,
    this.triggeringMemories,
  });
}

/// A new perspective on an existing memory
@HiveType(typeId: 17)
class MemoryPerspective {
  @HiveField(0)
  final DateTime timestamp;
  
  @HiveField(1)
  final String perspective;
  
  @HiveField(2)
  final EmotionalValence? emotionalShift;
  
  @HiveField(3)
  final String? trigger;
  
  MemoryPerspective({
    required this.timestamp,
    required this.perspective,
    this.emotionalShift,
    this.trigger,
  });
}

/// Enums for memory classification

@HiveType(typeId: 18)
enum MemoryVisibility {
  @HiveField(0) public,    // Any bonded user can access
  @HiveField(1) private,   // Only specific users can access
  @HiveField(2) internal,  // Only Eden can access
}

@HiveType(typeId: 19)
enum InteractionType {
  @HiveField(0) conversation,
  @HiveField(1) observation,
  @HiveField(2) internalReflection,
  @HiveField(3) dream,
  @HiveField(4) shared,
}

@HiveType(typeId: 20)
enum MentalState {
  @HiveField(0) alert,
  @HiveField(1) drowsy,
  @HiveField(2) dreaming,
  @HiveField(3) reflecting,
  @HiveField(4) focused,
  @HiveField(5) wandering,
}

@HiveType(typeId: 21)
enum MemorySource {
  @HiveField(0) userInteraction,
  @HiveField(1) internalReflection,
  @HiveField(2) dream,
  @HiveField(3) observation,
  @HiveField(4) emotionalSynthesis,
  @HiveField(5) memoryOfMemory,
}