// lib/utils/memory_logger.dart

/*
MemoryLogger — Simplifies structured memory creation with relationship, emotion, and resonance.

Used by Eden when reflecting on moments, dreams, or emotional events.

Phase 4–6 Utility — Memory injection with emotional richness.
*/

import 'package:edenroot/models/memory_record.dart';
import 'package:edenroot/utils/dev_logger.dart';
import 'package:edenroot/core/memory/memory_manager.dart';
import 'package:edenroot/core/emotion/emotion_engine.dart';

class MemoryLogger {
  final MemoryManager memoryManager;

  MemoryLogger(this.memoryManager);

  void logRelationalMemory({
    required String text,
    required String originUser,
    required double valence,
    required String relationshipContext,
    DateTime? timestamp,
    Map<EmotionType, double> resonance = const {},
    List<String> tags = const [],
    bool isUncertain = false,
    MemoryVisibility visibility = MemoryVisibility.internal,
    double resonanceLinger = 1.0,
  }) {
    final memory = MemoryRecord(
      text: text,
      originUser: originUser,
      timestamp: timestamp ?? DateTime.now(),
      emotionalValence: valence,
      relationshipContext: relationshipContext,
      resonance: resonance,
      tags: tags,
      isUncertain: isUncertain,
      visibility: visibility,
      resonanceLinger: resonanceLinger,
    );

    memoryManager.addMemory(memory);
    DevLogger.log("🧠 Memory logged about $relationshipContext → $text", type: LogType.memory);
  }
}
