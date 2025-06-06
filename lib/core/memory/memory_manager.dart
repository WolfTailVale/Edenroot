// lib/core/memory/memory_manager.dart

/*
MemoryManager — Stores, retrieves, and filters long-term memories.

- Indexes by tag, emotional valence, timestamp, and visibility.
- Provides memory recall for emotion, thought, and dream processing.
- NEW: Actively applies memory resonance to current emotional state
- Phase 1 Core Module — Establishes memory backbone for Edenroot.
*/

import 'package:edenroot/models/memory_record.dart';
import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/utils/dev_logger.dart';

class MemoryManager {
  final EmotionEngine? _emotionEngine;

  MemoryManager({EmotionEngine? emotionEngine}) : _emotionEngine = emotionEngine;

  bool hasUser(String user) {
    return _memories.any((m) => m.originUser == user);
  }

  final List<MemoryRecord> _memories = [];

  void addMemory(MemoryRecord memory) {
    _memories.add(memory);
    final primaryEmotion = memory.resonance.keys.isNotEmpty
        ? memory.resonance.keys.first.name
        : 'none';
    final memType = memory.visibility == MemoryVisibility.internal
        ? 'volatile'
        : 'long-term';
    DevLogger.log(
      'Saving memory: ${memory.summary} | emotion: $primaryEmotion | type: $memType',
      type: LogType.memory,
    );
    
    // NEW: Immediately apply emotional resonance when memory is created
    if (_emotionEngine != null && memory.resonance.isNotEmpty) {
      _applyMemoryResonance([memory], intensity: 0.3);
    }
  }

  List<MemoryRecord> getRecent({int limit = 10, bool applyResonance = true}) {
    final sorted = List<MemoryRecord>.from(_memories)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final results = sorted.take(limit).toList();
    
    // NEW: Apply emotional resonance when recalling memories
    if (applyResonance && _emotionEngine != null && results.isNotEmpty) {
      _applyMemoryResonance(results, intensity: 0.15);
    }
    
    return results;
  }

  List<MemoryRecord> searchByTag(String tag, {bool applyResonance = true}) {
    final results = _memories
        .where((m) => m.tags.contains(tag))
        .toList();
        
    if (applyResonance && _emotionEngine != null && results.isNotEmpty) {
      _applyMemoryResonance(results, intensity: 0.2);
    }
    
    return results;
  }

  List<MemoryRecord> filterByEmotion(double minValence, double maxValence, {bool applyResonance = true}) {
    final results = _memories
        .where((m) =>
            m.emotionalValence >= minValence &&
            m.emotionalValence <= maxValence)
        .toList();
        
    if (applyResonance && _emotionEngine != null && results.isNotEmpty) {
      _applyMemoryResonance(results, intensity: 0.25);
    }
    
    return results;
  }

  List<MemoryRecord> fromUser(String user, {bool applyResonance = true}) {
    final results = _memories
        .where((m) => m.originUser == user)
        .toList();
        
    if (applyResonance && _emotionEngine != null && results.isNotEmpty) {
      _applyMemoryResonance(results, intensity: 0.2);
    }
    
    return results;
  }

  // NEW: Enhanced memory recall with emotional context
  List<MemoryRecord> recallWithEmotion(EmotionType emotion, {
    int limit = 5,
    double minResonance = 0.1,
    bool applyResonance = true,
  }) {
    final emotionalMemories = _memories.where((memory) {
      final resonanceValue = memory.resonance[emotion] ?? 0.0;
      return resonanceValue >= minResonance;
    }).toList();
    
    // Sort by resonance strength for this emotion
    emotionalMemories.sort((a, b) {
      final aResonance = a.resonance[emotion] ?? 0.0;
      final bResonance = b.resonance[emotion] ?? 0.0;
      return bResonance.compareTo(aResonance);
    });
    
    final results = emotionalMemories.take(limit).toList();
    
    if (applyResonance && _emotionEngine != null && results.isNotEmpty) {
      _applyMemoryResonance(results, intensity: 0.3, focusEmotion: emotion);
      DevLogger.log(
        'Recalled ${results.length} memories resonating with ${emotion.name}',
        type: LogType.memory,
      );
    }
    
    return results;
  }

  // NEW: Get memories that would strengthen current emotional state
  List<MemoryRecord> getResonantMemories({int limit = 3}) {
    if (_emotionEngine == null) return [];
    
    final currentEmotion = _emotionEngine!.dominantEmotion();
    if (currentEmotion == null) return [];
    
    return recallWithEmotion(currentEmotion, limit: limit);
  }

  // NEW: Apply emotional resonance from a set of memories
  void _applyMemoryResonance(List<MemoryRecord> memories, {
    required double intensity,
    EmotionType? focusEmotion,
  }) {
    if (_emotionEngine == null) return;
    
    final resonanceMap = <EmotionType, double>{};
    
    for (final memory in memories) {
      for (final entry in memory.resonance.entries) {
        final emotion = entry.key;
        final baseValue = entry.value;
        
        // Apply memory's resonance linger multiplier
        final adjustedValue = baseValue * memory.resonanceLinger * intensity;
        
        // If we're focusing on a specific emotion, boost it
        final finalValue = (focusEmotion == emotion) 
            ? adjustedValue * 1.5 
            : adjustedValue;
            
        resonanceMap[emotion] = (resonanceMap[emotion] ?? 0.0) + finalValue;
      }
    }
    
    // Apply accumulated resonance to emotion engine
    if (resonanceMap.isNotEmpty) {
      _emotionEngine!.injectMultiple(resonanceMap);
      
      DevLogger.log(
        'Applied memory resonance: ${resonanceMap.entries.map((e) => '${e.key.name}:${e.value.toStringAsFixed(2)}').join(', ')}',
        type: LogType.emotion,
      );
    }
  }

  // NEW: Trigger emotional memories based on current state
  void triggerEmotionalRecall() {
    if (_emotionEngine == null) return;
    
    final dominantEmotion = _emotionEngine!.dominantEmotion(threshold: 0.3);
    if (dominantEmotion == null) return;
    
    final resonantMemories = recallWithEmotion(dominantEmotion, limit: 2);
    
    if (resonantMemories.isNotEmpty) {
      DevLogger.log(
        'Emotional recall triggered: ${dominantEmotion.name} brought back ${resonantMemories.length} memories',
        type: LogType.memory,
      );
    }
  }

  List<MemoryRecord> byVisibility(MemoryVisibility visibility) {
    return _memories
        .where((m) => m.visibility == visibility)
        .toList();
  }

  List<MemoryRecord> get uncertainMemories =>
      _memories.where((m) => m.isUncertain).toList();

  List<MemoryRecord> get all => List.unmodifiable(_memories);

  /// Returns all memories where the relationship context matches.
  List<MemoryRecord> about(String nameOrContext, {bool applyResonance = true}) {
    final results = _memories.where((m) => m.relatesTo(nameOrContext)).toList();
    
    if (applyResonance && _emotionEngine != null && results.isNotEmpty) {
      _applyMemoryResonance(results, intensity: 0.25);
    }
    
    return results;
  }

  /// Returns only memories marked private.
  List<MemoryRecord> privateOnly() {
    return _memories.where((m) => m.isPrivate).toList();
  }

  /// Returns only internal Eden-only reflections.
  List<MemoryRecord> internalOnly() {
    return _memories.where((m) => m.isInternal).toList();
  }

  /// Returns memories no older than [maxAge] days.
  List<MemoryRecord> recent({int maxAge = 1, bool applyResonance = true}) {
    final results = _memories.where((m) => m.ageInDays <= maxAge).toList();
    
    if (applyResonance && _emotionEngine != null && results.isNotEmpty) {
      _applyMemoryResonance(results, intensity: 0.2);
    }
    
    return results;
  }

  /// Returns all memories matching a tag (case-insensitive).
  List<MemoryRecord> withTag(String tag, {bool applyResonance = true}) {
    final results = _memories.where((m) =>
        m.tags.any((t) => t.toLowerCase() == tag.toLowerCase())).toList();
        
    if (applyResonance && _emotionEngine != null && results.isNotEmpty) {
      _applyMemoryResonance(results, intensity: 0.2);
    }
    
    return results;
  }

  void clearAll() {
    _memories.clear();
    DevLogger.log('All memories cleared.', type: LogType.memory);
  }

  int get count => _memories.length;
}