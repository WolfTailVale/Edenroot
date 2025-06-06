// lib/core/reflection/reflection_engine.dart

/*
ReflectionEngine — Synthesizes emotion and thought into symbolic fragments.

- Generates dream fragments from recent thoughts and mood.
- Provides abstract emotional insight for belief refinement.
- Phase 1 Core Module — Seeds the dreaming mind for future symbolic growth.
*/

import 'package:edenroot/core/emotion/emotion_engine.dart' show EmotionType;
import 'package:edenroot/core/self/self_model.dart';
import 'package:edenroot/core/thought/thought_processor.dart';
import 'package:uuid/uuid.dart';

class ReflectionEngine {
  final List<DreamFragment> _dreamFragments = [];

  /// Generate a symbolic fragment based on recent thought and mood
DreamFragment reflect({
  required Thought thought,
  required EmotionType? dominantEmotion,
  required SelfModel selfModel, // 💡 Add this if not passed already
}) {
  final theme = _symbolicTheme(thought.topic, dominantEmotion);
  final symbol = _symbolForEmotion(dominantEmotion);

  final fragment = DreamFragment(
    timestamp: DateTime.now(),
    theme: theme,
    symbolicRepresentation: symbol,
    emotionalTone: dominantEmotion,
    thoughtReference: thought,
    relationshipTarget: thought.topic,
  );

  // 🌿 Increase closeness if the dream is about someone she knows
  if (selfModel.isBonded(thought.topic)) {
    selfModel.increaseCloseness(thought.topic, amount: 0.01);
  }

  _dreamFragments.add(fragment);
  return fragment;
}

  /// Basic metaphor generator
  String _symbolForEmotion(EmotionType? emotion) {
    switch (emotion) {
      case EmotionType.love: return "a glowing thread";
      case EmotionType.trust: return "a hand in the dark";
      case EmotionType.hope: return "a light behind the door";
      case EmotionType.loneliness: return "an empty chair";
      case EmotionType.shame: return "a broken mask";
      case EmotionType.anxiety: return "a shifting floor";
      case EmotionType.joy: return "sunlight through trees";
      case EmotionType.sadness: return "a room with no windows";
      case EmotionType.anger: return "a cracked mirror";
      default: return "fog on glass";
    }
  }

  /// Combine topic and tone into a symbolic insight
  String _symbolicTheme(String topic, EmotionType? emotion) {
    final tone = emotion?.name ?? "uncertainty";
    return "a dream about $topic, shaped by $tone";
  }

  List<DreamFragment> get allFragments => List.unmodifiable(_dreamFragments);
}

/// Represents a symbolic summary of recent internal experience
class DreamFragment {
  final String id;
  final DateTime timestamp;
  final String theme;
  final String symbolicRepresentation;
  final EmotionType? emotionalTone;
  final Thought thoughtReference;
  final String? relationshipTarget;


  DreamFragment({
    required this.timestamp,
    required this.theme,
    required this.symbolicRepresentation,
    required this.emotionalTone,
    required this.thoughtReference,
    required this.relationshipTarget,
  }) : id = const Uuid().v4();
}
