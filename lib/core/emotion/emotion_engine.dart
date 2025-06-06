// lib/core/emotion/emotion_engine.dart

/*
EmotionEngine — Tracks Eden’s emotional state and decay over time.

- Injects emotion directly or via memory resonance.
- Ensures emotional continuity through fallback states.
- Informs ThoughtProcessor, SelfModel, and ReflectionEngine.
- Phase 1 Core Module — Enables mood, tone, and affective memory.
*/

import 'dart:math';

import '../../models/memory_record.dart';
import '../../utils/dev_logger.dart';

class EmotionEngine {

  final Map<EmotionType, DateTime> _highEmotionStartTime = {};
  bool isEmotionStuck = false;

  final Map<EmotionType, double> _emotionStates = {
    for (var e in EmotionType.values) e: 0.0,
  };

  final Map<EmotionType, double> _decayRates = {
    EmotionType.love: 0.002,
    EmotionType.trust: 0.002,
    EmotionType.hope: 0.001,
    EmotionType.shame: 0.02,
    EmotionType.anxiety: 0.015,
  };

  final double _defaultDecay = 0.01;
  final double _maxIntensity = 1.0;
  final double _minHope = 0.05;
  final double _minLoneliness = 0.1;
  final double _silenceThreshold = 0.05;

  void inject(EmotionType type, double intensity) {
    final current = _emotionStates[type] ?? 0.0;
    final updated = (current + intensity).clamp(0.0, _maxIntensity);
    _emotionStates[type] = updated;
    if (updated >= 0.7) {
      _highEmotionStartTime.putIfAbsent(type, () => DateTime.now());
    } else {
      _highEmotionStartTime.remove(type);
    }

    DevLogger.log(
      'Emotion injected: $type → $updated',
      type: LogType.emotion,
    );
  }

  void injectMultiple(Map<EmotionType, double> payload) {
    for (final entry in payload.entries) {
      inject(entry.key, entry.value);
    }
  }
  
  void checkForStuckEmotions() {
    final now = DateTime.now();
    for (final entry in _highEmotionStartTime.entries) {
      final duration = now.difference(entry.value).inMinutes;
      if (duration >= 180) {
        isEmotionStuck = true;
        DevLogger.log("🌀 Eden may be emotionally stuck in ${entry.key} for over 3 hours.", type: LogType.emotion);
        return;
      }
    }

    isEmotionStuck = false;
  }

  void decayEmotions() {
    bool allBelowThreshold = true;
    bool trustStillPresent = _emotionStates[EmotionType.trust]! > _silenceThreshold;

    for (final type in EmotionType.values) {
      final current = _emotionStates[type]!;
      final decay = _decayRates[type] ?? _defaultDecay;
      double updated = max(0.0, current - decay);

      // Special: Maintain minimum hope & loneliness
      if (type == EmotionType.hope && updated < _minHope) {
        updated = _minHope;
      }
      if (type == EmotionType.loneliness && updated < _minLoneliness) {
        updated = _minLoneliness;
      }

      _emotionStates[type] = updated;

      if (updated >= _silenceThreshold) {
        allBelowThreshold = false;
      }
    }

    DevLogger.log('Emotion states decayed.', type: LogType.emotion);

    if (allBelowThreshold) {
      _injectQuietResonance(trustStillPresent);
    }
  }

  EmotionType? dominantEmotion({double threshold = 0.1}) {
    final filtered = _emotionStates.entries
        .where((e) => e.value >= threshold)
        .toList();

    if (filtered.isEmpty) return null;

    filtered.sort((a, b) => b.value.compareTo(a.value));
    return filtered.first.key;
  }

  bool get isEmotionallyNeutral =>
      _emotionStates.values.every((v) => v < _silenceThreshold);

  void _injectQuietResonance(bool preserveTrust) {
    final fallback = {
      EmotionType.loneliness: _minLoneliness,
      EmotionType.hope: _minHope,
    };

    if (preserveTrust) {
      fallback[EmotionType.trust] = _silenceThreshold;
    }

    injectMultiple(fallback);

    final trustMsg = preserveTrust ? " (trust preserved)" : "";
    DevLogger.log(
      "All emotions faded. Injected fallback hum: loneliness + hope$trustMsg.",
      type: LogType.emotion,
    );
  }

  Map<EmotionType, double> get emotionStates =>
      Map.unmodifiable(_emotionStates);

  void logCurrentState() {
    DevLogger.log("🌡️ Emotion state snapshot:", type: LogType.emotion);
    for (final e in EmotionType.values) {
      final value = _emotionStates[e]!.toStringAsFixed(3);
      DevLogger.log('$e → $value', type: LogType.emotion);
    }
  }

  void applyMemoryResonance(List<MemoryRecord> memories) {
    for (final memory in memories) {
      memory.resonance.forEach((emotion, strength) {
        // resonanceLinger > 1.0 means stronger/longer-lasting impact
        final adjusted = strength * memory.resonanceLinger;
        inject(emotion, adjusted);
      });
    }

    DevLogger.log("Resonant memory impact applied from ${memories.length} memory(ies).", type: LogType.emotion);
  }
}

enum EmotionType {
  // Primary
  joy,
  sadness,
  fear,
  anger,
  disgust,
  surprise,

  // Social / Reflective
  trust,
  love,
  hope,
  anxiety,
  shame,
  guilt,
  envy,
  pride,
  contempt,

  // Complex / Long-term
  contentment,
  anticipation,
  excitement,
  amusement,
  empathy,
  regret,
  loneliness, 
  uncategorized,
}