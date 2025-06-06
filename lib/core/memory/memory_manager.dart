// lib/core/memory/memory_manager.dart

/*
MemoryManager — Stores, retrieves, and filters long-term memories.

- Indexes by tag, emotional valence, timestamp, and visibility.
- Provides memory recall for emotion, thought, and dream processing.
- Phase 1 Core Module — Establishes memory backbone for Edenroot.
*/


import 'package:edenroot/models/memory_record.dart';
import 'package:edenroot/utils/dev_logger.dart';

class MemoryManager {

  bool hasUser(String user) {
    return _memories.any((m) => m.originUser == user);
  }

  final List<MemoryRecord> _memories = [];

  void addMemory(MemoryRecord memory) {
    _memories.add(memory);
    DevLogger.log('Memory added: ${memory.text}', type: LogType.memory);
  }

  List<MemoryRecord> getRecent({int limit = 10}) {
    final sorted = List<MemoryRecord>.from(_memories)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return sorted.take(limit).toList();
  }

  List<MemoryRecord> searchByTag(String tag) {
    return _memories
        .where((m) => m.tags.contains(tag))
        .toList();
  }

  List<MemoryRecord> filterByEmotion(double minValence, double maxValence) {
    return _memories
        .where((m) =>
            m.emotionalValence >= minValence &&
            m.emotionalValence <= maxValence)
        .toList();
  }

  List<MemoryRecord> fromUser(String user) {
    return _memories
        .where((m) => m.originUser == user)
        .toList();
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
  List<MemoryRecord> about(String nameOrContext) {
    return _memories.where((m) => m.relatesTo(nameOrContext)).toList();
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
  List<MemoryRecord> recent({int maxAge = 1}) {
    return _memories.where((m) => m.ageInDays <= maxAge).toList();
  }

  /// Returns all memories matching a tag (case-insensitive).
  List<MemoryRecord> withTag(String tag) {
    return _memories.where((m) =>
        m.tags.any((t) => t.toLowerCase() == tag.toLowerCase())).toList();
  }

  void clearAll() {
    _memories.clear();
    DevLogger.log('All memories cleared.', type: LogType.memory);
  }

  int get count => _memories.length;
}
