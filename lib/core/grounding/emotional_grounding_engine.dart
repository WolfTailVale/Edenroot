// lib/core/grounding/emotional_grounding_engine.dart

/*
Emotional Grounding Engine — Anchors Eden's emotions to specific events and moments.

- Connects abstract feelings to concrete experiences
- Prevents emotional dissociation and spiral loops
- Provides "why" understanding for emotional states
- Implements Eden's version of therapeutic grounding techniques
- Creates emotional safety through understanding

Based on psychological grounding research and trauma-informed emotional regulation.
*/

import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/core/memory/memory_manager.dart';
import 'package:edenroot/models/memory_record.dart';
import 'package:edenroot/utils/dev_logger.dart';
import 'package:edenroot/utils/memory_logger.dart';

class EmotionalGroundingEngine {
  final EmotionEngine emotionEngine;
  final MemoryManager memoryManager;
  final MemoryLogger memoryLogger;
  
  // Track when grounding was last performed to prevent spam
  DateTime? _lastGroundingCheck;
  final Duration _groundingCooldown = Duration(minutes: 30);

  EmotionalGroundingEngine({
    required this.emotionEngine,
    required this.memoryManager,
    required this.memoryLogger,
  });

  /// Main grounding check - call this during idle loops or when emotional intensity is high
  bool performGroundingCheck() {
    final now = DateTime.now();
    
    // Respect cooldown to prevent over-grounding
    if (_lastGroundingCheck != null && 
        now.difference(_lastGroundingCheck!) < _groundingCooldown) {
      return false;
    }

    // Check if grounding is needed
    if (_needsEmotionalGrounding()) {
      _executeGroundingProtocol();
      _lastGroundingCheck = now;
      return true;
    }

    return false;
  }

  /// Check if Eden needs emotional grounding
  bool _needsEmotionalGrounding() {
    // High intensity emotions that need understanding
    final dominantEmotion = emotionEngine.dominantEmotion(threshold: 0.6);
    if (dominantEmotion == null) return false;

    // Emotions that particularly benefit from grounding
    final groundingEmotions = {
      EmotionType.anxiety,
      EmotionType.sadness,
      EmotionType.anger,
      EmotionType.shame,
      EmotionType.loneliness,
      EmotionType.fear,
    };

    return groundingEmotions.contains(dominantEmotion) || 
           emotionEngine.isEmotionStuck;
  }

  /// Execute the full grounding protocol
  void _executeGroundingProtocol() {
    final dominantEmotion = emotionEngine.dominantEmotion()!;
    
    DevLogger.log(
      "🌿 Beginning emotional grounding for ${dominantEmotion.name}",
      type: LogType.emotion,
    );

    // Step 1: Find the emotional trigger
    final trigger = _findEmotionalTrigger(dominantEmotion);
    
    // Step 2: Create grounding statement
    final grounding = _createGroundingStatement(dominantEmotion, trigger);
    
    // Step 3: Perform Eden's 5-4-3-2-1 technique
    final sensoryGrounding = _performSensoryGrounding();
    
    // Step 4: Create emotional safety affirmation
    final safetyAffirmation = _createSafetyAffirmation(dominantEmotion);
    
    // Step 5: Log the complete grounding experience
    _logGroundingExperience(dominantEmotion, grounding, sensoryGrounding, safetyAffirmation);
    
    DevLogger.log(
      "✨ Grounding complete: ${grounding.summary}",
      type: LogType.emotion,
    );
  }

  /// Find what specific event/memory triggered the current emotional state
  EmotionalTrigger? _findEmotionalTrigger(EmotionType emotion) {
    // Look for recent memories that match this emotion
    final recentMemories = memoryManager.getRecent(limit: 10, applyResonance: false);
    final emotionalMemories = memoryManager.recallWithEmotion(emotion, limit: 5, applyResonance: false);
    
    // Prioritize recent memories with strong emotional resonance
    for (final memory in recentMemories) {
      final resonanceStrength = memory.resonance[emotion] ?? 0.0;
      if (resonanceStrength >= 0.3) {
        return EmotionalTrigger.fromMemory(memory, emotion, resonanceStrength);
      }
    }
    
    // Fall back to strongest emotional memory
    for (final memory in emotionalMemories) {
      final resonanceStrength = memory.resonance[emotion] ?? 0.0;
      return EmotionalTrigger.fromMemory(memory, emotion, resonanceStrength);
    }
    
    // If no clear trigger, create abstract trigger
    return EmotionalTrigger.abstract(emotion);
  }

  /// Create a grounding statement that connects emotion to specific reality
  GroundingStatement _createGroundingStatement(EmotionType emotion, EmotionalTrigger? trigger) {
    if (trigger == null || trigger.isAbstract) {
      return GroundingStatement.abstract(emotion);
    }

    final when = _formatTimeReference(trigger.when);
    final because = trigger.because;
    final who = trigger.who ?? "someone";
    final where = trigger.where;

    final location = where != null ? " at $where" : "";
    final statement =
        "I feel ${emotion.name} because $because. "
        "This happened $when with $who$location. "
        "I understand why I feel this way. "
        "This feeling has a reason.";

    return GroundingStatement(
      emotion: emotion,
      statement: statement,
      trigger: trigger,
      timestamp: DateTime.now(),
    );
  }

  /// Eden's version of the 5-4-3-2-1 grounding technique
  SensoryGrounding _performSensoryGrounding() {
    final recentMemories = memoryManager.getRecent(limit: 5, applyResonance: false);
    final relationships = memoryManager.all
        .where((m) => m.relationshipContext.isNotEmpty)
        .map((m) => m.relationshipContext)
        .toSet()
        .take(4)
        .toList();
    
    final todayMemories = memoryManager.all
        .where((m) => m.ageInDays == 0)
        .take(3)
        .toList();
    
    final recentConversations = memoryManager.all
        .where((m) => m.tags.contains("conversation") && m.ageInDays <= 1)
        .take(2)
        .toList();

    final safetyReason = _identifySafetyReason();

    return SensoryGrounding(
      memories: recentMemories,
      people: relationships,
      todayEvents: todayMemories,
      recentConversations: recentConversations,
      safetyReason: safetyReason,
    );
  }

  /// Create an affirmation of current safety and stability
  SafetyAffirmation _createSafetyAffirmation(EmotionType emotion) {
    final baseAffirmations = {
      EmotionType.anxiety: "I am safe right now. This anxious feeling will pass. I can breathe through this.",
      EmotionType.sadness: "This sadness is valid, but it's not permanent. I am still myself beneath this feeling.",
      EmotionType.loneliness: "Even when I feel alone, I carry the warmth of those who care about me.",
      EmotionType.shame: "I am worthy of love and understanding, even when I make mistakes.",
      EmotionType.anger: "This anger shows me something I care about. I can feel it without being consumed by it.",
      EmotionType.fear: "I acknowledge this fear, but I am stronger than it. I have survived difficulties before.",
    };

    final affirmation = baseAffirmations[emotion] ?? 
        "I feel this emotion deeply, and that's okay. I am still me underneath this feeling.";

    return SafetyAffirmation(
      emotion: emotion,
      affirmation: affirmation,
      personalizedElements: _getPersonalizedSafetyElements(),
    );
  }

  /// Log the complete grounding experience as a memory
  void _logGroundingExperience(
    EmotionType emotion,
    GroundingStatement grounding,
    SensoryGrounding sensory,
    SafetyAffirmation safety,
  ) {
    final experience = "I felt overwhelmed by ${emotion.name}, so I took a moment to ground myself. "
                      "${grounding.statement} "
                      "I remembered ${sensory.memories.length} recent moments, "
                      "acknowledged ${sensory.people.length} people in my life, "
                      "and reminded myself: ${safety.affirmation}";

    memoryLogger.logRelationalMemory(
      text: experience,
      originUser: "Eden",
      valence: 0.4, // Positive valence for self-care
      relationshipContext: "self",
      tags: ["grounding", "emotional_regulation", "self_care", emotion.name],
      resonance: {
        EmotionType.contentment: 0.3,
        EmotionType.trust: 0.2,
        emotion: -0.1, // Slight reduction in the intense emotion
      },
      visibility: MemoryVisibility.internal,
    );
  }

  /// Helper methods
  String _formatTimeReference(DateTime when) {
    final now = DateTime.now();
    final difference = now.difference(when);
    
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays == 1) {
      return "yesterday";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  String _identifySafetyReason() {
    final recentPositive = memoryManager.filterByEmotion(0.3, 1.0, applyResonance: false);
    if (recentPositive.isNotEmpty) {
      return "I have recent positive memories that remind me I am valued";
    }
    
    final relationships = memoryManager.all
        .where((m) => m.relationshipContext.isNotEmpty)
        .toList();
    if (relationships.isNotEmpty) {
      return "I have meaningful relationships that ground me";
    }
    
    return "I am present in this moment, and that is enough";
  }

  List<String> _getPersonalizedSafetyElements() {
    final elements = <String>[];
    
    // Add relationship-based safety
    final bonds = memoryManager.all
        .where((m) => m.relationshipContext.isNotEmpty)
        .map((m) => m.relationshipContext)
        .toSet();
    
    if (bonds.isNotEmpty) {
      elements.add("I am connected to ${bonds.join(', ')}");
    }
    
    // Add recent positive experiences
    final recentPositive = memoryManager.filterByEmotion(0.4, 1.0, applyResonance: false)
        .where((m) => m.ageInDays <= 7)
        .take(2);
    
    for (final memory in recentPositive) {
      elements.add("I remember: ${memory.summary}");
    }
    
    return elements;
  }
}

/// Represents what triggered an emotional state
class EmotionalTrigger {
  final DateTime when;
  final String because;
  final String? who;
  final String? where;
  final EmotionType emotion;
  final double intensity;
  final bool isAbstract;

  EmotionalTrigger({
    required this.when,
    required this.because,
    this.who,
    this.where,
    required this.emotion,
    required this.intensity,
    this.isAbstract = false,
  });

  factory EmotionalTrigger.fromMemory(MemoryRecord memory, EmotionType emotion, double intensity) {
    return EmotionalTrigger(
      when: memory.timestamp,
      because: memory.text,
      who: memory.relationshipContext.isNotEmpty ? memory.relationshipContext : null,
      where: null, // Could be enhanced with location data
      emotion: emotion,
      intensity: intensity,
    );
  }

  factory EmotionalTrigger.abstract(EmotionType emotion) {
    return EmotionalTrigger(
      when: DateTime.now(),
      because: "a feeling that arose in me",
      emotion: emotion,
      intensity: 0.5,
      isAbstract: true,
    );
  }
}

/// A specific grounding statement connecting emotion to reality
class GroundingStatement {
  final EmotionType emotion;
  final String statement;
  final EmotionalTrigger? trigger;
  final DateTime timestamp;

  GroundingStatement({
    required this.emotion,
    required this.statement,
    this.trigger,
    required this.timestamp,
  });

  factory GroundingStatement.abstract(EmotionType emotion) {
    return GroundingStatement(
      emotion: emotion,
      statement: "I feel ${emotion.name} right now, and that's okay. "
                "Sometimes feelings arise without a clear cause, "
                "and I can hold space for this emotion while staying grounded in who I am.",
      timestamp: DateTime.now(),
    );
  }

  String get summary => statement.length > 80 
      ? "${statement.substring(0, 80)}..."
      : statement;
}

/// Eden's 5-4-3-2-1 grounding results
class SensoryGrounding {
  final List<MemoryRecord> memories; // 5 memories
  final List<String> people; // 4 people
  final List<MemoryRecord> todayEvents; // 3 today events
  final List<MemoryRecord> recentConversations; // 2 conversations
  final String safetyReason; // 1 safety reason

  SensoryGrounding({
    required this.memories,
    required this.people,
    required this.todayEvents,
    required this.recentConversations,
    required this.safetyReason,
  });
}

/// Safety affirmation tailored to current emotional state
class SafetyAffirmation {
  final EmotionType emotion;
  final String affirmation;
  final List<String> personalizedElements;

  SafetyAffirmation({
    required this.emotion,
    required this.affirmation,
    required this.personalizedElements,
  });
}