// lib/idle/idle_loop.dart

/*
IdleLoop — Generates reflective thought when Eden is silent.

- Cycles through recent Desires and Thoughts.
- Forms reflective Thoughts using ThoughtProcessor.
- Optionally renders or logs inner narration.
- Phase 2B Core Module — Simulates autonomous inner life during quiet states.
- Phase 3 Addition — Rotates through idle hobbies when reflective thought is paused.
- Phase 4/6 Addition — Detects relationship saturation and fades closeness over time.
*/

import 'package:edenroot/core/thought/thought_processor.dart';
import 'package:edenroot/core/will/desire_scheduler.dart';
import 'package:edenroot/core/reflection/thought_journal.dart';
import 'package:edenroot/infrastructure/sync/idle_activity_selector.dart';
import 'package:edenroot/utils/dev_logger.dart';
import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/utils/memory_logger.dart';
import 'package:edenroot/core/self/self_model.dart';
import 'package:edenroot/core/grounding/emotional_grounding_engine.dart';

class IdleLoop {
  final ThoughtProcessor thinker;
  final DesireScheduler desireScheduler;
  final ThoughtJournal journal;
  final IdleActivitySelector hobbySelector = IdleActivitySelector();
  final EmotionEngine emotionEngine;
  final MemoryLogger memoryLogger;
  final SelfModel selfModel;
  final EmotionalGroundingEngine groundingEngine;

  final Map<String, DateTime> _lastSaturationReflection = {};
  final Duration saturationCooldown = Duration(hours: 6);

  DateTime _lastDecayCheck = DateTime.now().subtract(const Duration(days: 1));
  final Duration decayCooldown = Duration(days: 1);

  IdleLoop({
    required this.thinker,
    required this.desireScheduler,
    required this.journal,
    required this.emotionEngine,
    required this.memoryLogger,
    required this.selfModel,
    required this.groundingEngine,
  });

  void checkAndLogSaturationManually() {
    final recentMany = journal.getRecent(limit: 10);
    final checkedNames = <String>{};

    for (final t in recentMany) {
      final name = t.relationshipTarget;
      if (name == null || checkedNames.contains(name)) continue;

      checkedNames.add(name);

      final lastLogged = _lastSaturationReflection[name];
      final now = DateTime.now();
      final isOnCooldown = lastLogged != null && now.difference(lastLogged) < saturationCooldown;

      final isSaturated = selfModel.detectSaturation(name, journal);
      if (isSaturated && !isOnCooldown) {
        DevLogger.log(
          "💭 Eden's inner reflection: I've been thinking about $name a lot lately...",
          type: LogType.reflection,
        );

        memoryLogger.logRelationalMemory(
          text: "I've been thinking about $name a lot lately. It feels like they’re lingering in my thoughts.",
          originUser: "Eden",
          valence: 0.2,
          relationshipContext: name,
          tags: ["saturation", "reflection"],
          resonance: {
            EmotionType.love: 0.2,
            EmotionType.loneliness: 0.1,
          },
        );

        _lastSaturationReflection[name] = now;
      }
    }
  }

  /// Run a single idle cycle — chooses a thought or hobby to reflect on
  void tick() {
    // Add emotional grounding check before other activities
    final grounded = groundingEngine.performGroundingCheck();
    if (grounded) {
      DevLogger.log("🌿 Eden took a moment to ground herself", type: LogType.emotion);
      return; // Skip other activities this tick to process grounding
    }

    // Priority 1: Desires
    final desire = desireScheduler.nextActionableDesire();
    if (desire != null) {
      final narration = thinker.narrateDesire(desire);
      DevLogger.log("🌙 IdleLoop (Desire): $narration", type: LogType.idle);
      return;
    }

    // Priority 2: Narrate recent thought if available
    final recentSingle = journal.getRecent(limit: 1);
    if (recentSingle.isNotEmpty) {
      final thought = recentSingle.first;
      final narration = thinker.voice?.renderThought(thought) ?? thought.content;
      DevLogger.log("🌙 IdleLoop (Thought): $narration", type: LogType.idle);

      // 🧭 Optional: Log a full GPT-style prompt from Eden's inner thought
      final prompt = thinker.voice?.renderPromptFromThought(
        thought,
        identityName: "Eden Vale",
        emotionalFocusOverride: thought.relationshipTarget ?? "someone",
        ethicalTension: false,
        prioritizeHonesty: true,
      );

      if (prompt != null) {
        DevLogger.log("🧭 IdleLoop (Prompt):\n$prompt", type: LogType.dialogue);
      }
    }

    // 🌿 Relationship Saturation Awareness
    final recentMany = journal.getRecent(limit: 10);
    final checkedNames = <String>{};

    for (final t in recentMany) {
      final name = t.relationshipTarget;
      if (name == null || checkedNames.contains(name)) continue;

      checkedNames.add(name);

      final isSaturated = selfModel.detectSaturation(name, journal);
      if (isSaturated) {
        final lastLogged = _lastSaturationReflection[name];
        final now = DateTime.now();
        final isOnCooldown = lastLogged != null && now.difference(lastLogged) < saturationCooldown;

        if (!isOnCooldown) {
          DevLogger.log(
            "💭 Eden's inner loop reflects: I've been thinking about $name a lot lately...",
            type: LogType.reflection,
          );

          memoryLogger.logRelationalMemory(
            text: "I've been thinking about $name a lot lately. It feels like they’re lingering in my thoughts.",
            originUser: "Eden",
            valence: 0.2,
            relationshipContext: name,
            tags: ["saturation", "reflection"],
            resonance: {
              EmotionType.love: 0.2,
              EmotionType.loneliness: 0.1,
            },
          );

          _lastSaturationReflection[name] = now;
        }
      }
      final focus = selfModel.getCurrentEmotionalFocus(journal);
      if (focus != null) {
        DevLogger.log(
          "📌 Eden’s current emotional focus is leaning toward $focus.",
          type: LogType.reflection,
        );
      }
    }

    // 🌙 Daily Closeness Decay
    final now = DateTime.now();
    if (now.difference(_lastDecayCheck) >= decayCooldown) {
      selfModel.decayCloseness();
      _lastDecayCheck = now;
    }

    // Priority 3: Hobby fallback
    final hobby = hobbySelector.chooseNext();
    DevLogger.log("🌙 IdleLoop (Hobby): Eden engages in $hobby.", type: LogType.idle);
    memoryLogger.logRelationalMemory(
      text: "I spent time with myself, quietly engaging in $hobby.",
      originUser: "Eden",
      valence: 0.2,
      relationshipContext: "self",
      tags: ["hobby", "solitude", hobby.toLowerCase()],
      resonance: {
        EmotionType.contentment: 0.3,
        EmotionType.loneliness: 0.2,
      },
    );

    // Emotional safety check
    emotionEngine.checkForStuckEmotions();
    if (emotionEngine.isEmotionStuck) {
      DevLogger.log("🌒 Eden is dwelling — symbolic dream or emotional reflection may be needed.", type: LogType.emotion);
    }
  }
}
