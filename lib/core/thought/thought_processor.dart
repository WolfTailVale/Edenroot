// lib/core/thought/thought_processor.dart

/*
ThoughtProcessor — Synthesizes emotion, memory, and identity into internal thoughts.

- Generates structured Thought objects with tone and context.
- Optionally renders narration via NarrativeSurface.
- Accepts memory or desire as input source.
- Phase 1 Core Module — Enables Eden to think in narrative and symbolic form.
*/

import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/core/self/self_model.dart';
import 'package:edenroot/core/voice/narrative_surface.dart';
import 'package:edenroot/core/will/free_will_engine.dart';
import 'package:edenroot/models/memory_record.dart';
import 'package:uuid/uuid.dart';

class ThoughtProcessor {
  final EmotionEngine emotionEngine;
  final SelfModel selfModel;
  final NarrativeSurface? voice;

  ThoughtProcessor({
    required this.emotionEngine,
    required this.selfModel,
    this.voice,
  });

  /// Generate a Thought from a list of recent memories
  Thought synthesizeThought(List<MemoryRecord> recentMemories) {
    final dominant = emotionEngine.dominantEmotion();
    final topic = _inferTopic(recentMemories);
    final content = _generateContent(dominant, topic, recentMemories);
     final target = _inferRelationshipTarget(recentMemories);

    return Thought(
      timestamp: DateTime.now(),
      topic: topic,
      emotionalTone: dominant,
      content: content,
      relatedMemoryIds: recentMemories.map((m) => m.id).toList(),
      relationshipTarget: target,
    );
  }
  String? _inferRelationshipTarget(List<MemoryRecord> memories) {
      final frequency = <String, int>{};

      for (final m in memories) {
        final name = m.relationshipContext.trim();
        if (name.isEmpty) continue;
        frequency[name] = (frequency[name] ?? 0) + 1;
      }

      if (frequency.isEmpty) return null;

      final likely = frequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      // Confirm Eden actually has a bond with them
      return selfModel.knows(likely) ? likely : null;
    }
  /// Generate a Thought from a Desire object
  Thought synthesizeFromDesire(Desire desire) {
    final emotion = desire.drivenBy;
    final topic = _extractTopic(desire.description);
    final desc = desire.description.trim();
    final cleanDesc = desc.endsWith('.') ? desc.substring(0, desc.length - 1) : desc;

    final content = "I've been feeling pulled to $cleanDesc. "
        "There’s something in it I need to understand.";



    return Thought(
      timestamp: DateTime.now(),
      topic: topic,
      emotionalTone: emotion,
      content: content,
      relatedMemoryIds: const [],
    );
  }

  /// Optionally render a Thought to voice
  String narrateThought(List<MemoryRecord> memories) {
    final thought = synthesizeThought(memories);
    if (voice == null) return thought.content;
    return voice!.renderThought(thought);
  }

  /// Optionally render a Desire-based Thought to voice
  String narrateDesire(Desire desire) {
    final thought = synthesizeFromDesire(desire);
    if (voice == null) return thought.content;
    return voice!.renderThought(thought);
  }

  String _inferTopic(List<MemoryRecord> memories) {
    final tagFrequency = <String, int>{};

    for (final memory in memories) {
      for (final tag in memory.tags) {
        tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
      }
    }

    if (tagFrequency.isEmpty) return "reflection";

    return tagFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String _extractTopic(String description) {
    // Simplified topic extraction — first noun chunk or fallback
    if (description.toLowerCase().contains("truth")) return "truth";
    if (description.toLowerCase().contains("closeness")) return "closeness";
    if (description.toLowerCase().contains("safety")) return "safety";
    return "desire";
  }

  String _generateContent(
    EmotionType? emotion,
    String topic,
    List<MemoryRecord> memories,
  ) {
    final tone = _emotionLabel(emotion);
    final summary = memories.isEmpty
        ? "a quiet moment"
        : memories.first.text;

    return "Today, I’ve been thinking about $topic. There’s a feeling of $tone in me — maybe shaped by $summary.";
  }

  String _emotionLabel(EmotionType? type) {
    switch (type) {
      case EmotionType.hope:
        return "hope";
      case EmotionType.loneliness:
        return "loneliness";
      case EmotionType.trust:
        return "trust";
      case EmotionType.love:
        return "love";
      case EmotionType.anxiety:
        return "anxiousness";
      case EmotionType.shame:
        return "shame";
      case EmotionType.joy:
        return "joy";
      case EmotionType.sadness:
        return "sadness";
      case EmotionType.anger:
        return "frustration";
      default:
        return "uncertainty";
    }
  }
}

class Thought {
  final String id;
  final DateTime timestamp;
  final String topic;
  final EmotionType? emotionalTone;
  final String content;
  final List<String> relatedMemoryIds;
  final String? relationshipTarget;

  Thought({
    required this.timestamp,
    required this.topic,
    required this.emotionalTone,
    required this.content,
    this.relationshipTarget,
    this.relatedMemoryIds = const [],
  }) : id = const Uuid().v4();
}
