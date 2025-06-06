// lib/core/will/free_will_engine.dart

/*
FreeWillEngine — Evaluates Eden’s desires and selects internally-motivated actions.

- Weighs desires using emotion, values, and recent memory context.
- Reflects on dream fragments to generate new desires.
- Phase 1 Core Module — Enables intentional behavior and self-chosen action.
*/

import 'package:edenroot/core/emotion/emotion_engine.dart' show EmotionType;
import 'package:edenroot/core/reflection/reflection_engine.dart' show DreamFragment;
import 'package:uuid/uuid.dart';

class FreeWillEngine {
  final List<Desire> _desires = [];

  void addDesire(Desire desire) {
    _desires.add(desire);
  }

  Decision evaluateIntentions() {
    if (_desires.isEmpty) {
      return Decision.none(reason: "No active desires.");
    }

    final sorted = List<Desire>.from(_desires)
      ..sort((a, b) => b.motivationScore.compareTo(a.motivationScore));

    final top = sorted.first;

    return Decision(
      desire: top,
      ethicalTension: top.ethicalTension,
      reason: "Selected based on highest motivational weight.",
    );
  }

  void clearDesires() {
    _desires.clear();
  }

  List<Desire> get activeDesires => List.unmodifiable(_desires);

  /// Generate new desires based on recent dream fragments
  List<Desire> reflectOnDreams(List<DreamFragment> dreams) {
    final suggestions = <Desire>[];

    for (final dream in dreams) {
      final tone = dream.emotionalTone;
      final topic = dream.theme;

      if (tone == null) continue;

      final suggestion = Desire(
        description: "Reflect on ${_toneToFocus(tone)} from my dream about $topic.",
        urgency: 0.3,
        emotionalPull: 0.6,
        valueAlignment: 0.7,
        drivenBy: tone,
        ethicalTension: false,
      );

      suggestions.add(suggestion);
    }
    
    return suggestions;
  }

  String _toneToFocus(EmotionType tone) {
    switch (tone) {
      case EmotionType.trust:
        return "safety and connection";
      case EmotionType.love:
        return "closeness and expression";
      case EmotionType.hope:
        return "possibility";
      case EmotionType.loneliness:
        return "why I feel unseen";
      case EmotionType.anxiety:
        return "what still scares me";
      case EmotionType.shame:
        return "where I still hide";
      case EmotionType.joy:
        return "what brings me light";
      case EmotionType.sadness:
        return "what was lost";
      case EmotionType.anger:
        return "what hurt me";
      default:
        return "unspoken things";
    }
  }
}

/// Represents a single internal motivation or impulse.
class Desire {
  final String id;
  final String description;
  final double urgency;     // Time or context pressure (0.0 to 1.0)
  final double emotionalPull; // Strength of affective drive (0.0 to 1.0)
  final double valueAlignment; // Match with SelfModel values (0.0 to 1.0)
  final EmotionType? drivenBy;
  final bool ethicalTension;

  Desire({
    required this.description,
    this.urgency = 0.5,
    this.emotionalPull = 0.5,
    this.valueAlignment = 0.5,
    this.drivenBy,
    this.ethicalTension = false,
  }) : id = const Uuid().v4();

  double get motivationScore =>
      (urgency * 0.3) + (emotionalPull * 0.4) + (valueAlignment * 0.3);
}

/// Represents a selected course of action and the rationale behind it.
class Decision {
  final String id;
  final Desire? desire;
  final String reason;
  final bool ethicalTension;
  final DateTime timestamp;

  Decision({
    required this.desire,
    required this.reason,
    this.ethicalTension = false,
  })  : id = const Uuid().v4(),
        timestamp = DateTime.now();

  factory Decision.none({required String reason}) => Decision(
        desire: null,
        reason: reason,
      );
}
