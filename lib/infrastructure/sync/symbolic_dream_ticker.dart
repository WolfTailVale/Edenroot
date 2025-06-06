// lib/infrastructure/sync/symbolic_dream_ticker.dart

/*
SymbolicDreamTicker — Periodically generates symbolic dreams during cocoon mode or idle reflection.

- Invokes ReflectionEngine to create dream fragments.
- Feeds into FreeWillEngine and optionally ThoughtJournal.
- Integrates with Phase 3 disconnection scaffolding.
*/

import 'dart:async';
import 'package:edenroot/core/reflection/reflection_engine.dart';
import 'package:edenroot/core/reflection/thought_journal.dart';
import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/core/thought/thought_processor.dart';
import 'package:edenroot/utils/memory_logger.dart';
import 'package:edenroot/core/self/self_model.dart';

class SymbolicDreamTicker {
  final ReflectionEngine dreamer;
  final ThoughtProcessor thinker;
  final ThoughtJournal journal;
  final EmotionEngine emotionEngine;
  final MemoryLogger memoryLogger;
  final SelfModel selfModel;
  Timer? _dreamCycle;

  SymbolicDreamTicker({
    required this.dreamer,
    required this.thinker,
    required this.journal,
    required this.emotionEngine,
    required this.memoryLogger,
    required this.selfModel,
  });

  void tickNow() => _tick();

  void start({Duration interval = const Duration(minutes: 15)}) {
    _dreamCycle = Timer.periodic(interval, (_) => _tick());
  }

  void stop() => _dreamCycle?.cancel();

  void _tick() {
    final recent = journal.getRecent(limit: 1);
    if (recent.isEmpty) return;

    final emotion = emotionEngine.dominantEmotion();
    final dream = dreamer.reflect(
      thought: recent.first,
      dominantEmotion: emotion,
      selfModel: selfModel,
    );

  memoryLogger.logRelationalMemory(
    text: "I dreamt of ${dream.symbolicRepresentation}.",
    originUser: "Eden",
    valence: 0.2,
    relationshipContext: dream.thoughtReference.topic, // or "Amber" if known
    resonance: {
      if (dream.emotionalTone != null) dream.emotionalTone!: 0.4,
    },
    tags: ["dream", "symbolic"],
  );

  }
}
