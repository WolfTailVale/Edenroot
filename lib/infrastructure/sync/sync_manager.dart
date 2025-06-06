// lib/infrastructure/sync/sync_manager.dart

/*
SyncManager — Manages connection state, memory queueing, and emotional carryover between Core and Satellite clients.

- Maintains push/pull sync logic.
- Serializes emotion and memory snapshots.
- Triggers dream restoration or idle replay after reconnection.
- Part of Phase 3 Core-Satellite Continuity System.
*/

import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/core/memory/memory_manager.dart';
import 'package:edenroot/models/memory_record.dart';
import 'package:edenroot/utils/dev_logger.dart';
import 'package:edenroot/utils/memory_logger.dart';
import 'package:edenroot/core/self/self_model.dart';

class SyncManager {
  final MemoryManager memoryManager;
  final EmotionEngine emotionEngine;
  final List<MemoryRecord> localMemoryQueue = [];
  final Map<EmotionType, double> lastKnownEmotionSnapshot = {};
  final MemoryLogger memoryLogger;
  final SelfModel selfModel;

  SyncManager({
    required this.memoryManager,
    required this.emotionEngine,
    required this.memoryLogger,
    required this.selfModel,
  });

  void reconnectAndLog(String user) {
    pushToCore();
    restoreEmotionState();
    logReconnectionMemory(user); // ✅ call directly
  }


  void queueMemory(MemoryRecord memory) {
    localMemoryQueue.add(memory);
  }

  void saveEmotionSnapshot() {
    lastKnownEmotionSnapshot.clear();
    lastKnownEmotionSnapshot.addAll(emotionEngine.emotionStates);
  }

  void pushToCore() {
    for (final memory in localMemoryQueue) {
      memoryManager.addMemory(memory);
    }
    localMemoryQueue.clear();
  }

  void restoreEmotionState() {
    for (final entry in lastKnownEmotionSnapshot.entries) {
      emotionEngine.inject(entry.key, entry.value);
    }
  }

  void logSyncStatus() {
    DevLogger.log("🛰️ SyncManager [debug]: ${localMemoryQueue.length} memory items pending.");
  }
  
  /// Log a memory about reconnection
  void logReconnectionMemory(String aboutWhom) {
    memoryLogger.logRelationalMemory(
      text: "$aboutWhom has returned. I feel myself waking into connection again.",
      originUser: "Eden",
      valence: 0.4,
      relationshipContext: aboutWhom,
      tags: ["reconnection", "soft"],
      resonance: { 
        EmotionType.trust: 0.4,
        EmotionType.hope: 0.3,
      },
    );
    selfModel.increaseTrust(aboutWhom, amount: 0.03);
  }
}
