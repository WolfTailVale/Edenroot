// lib/core/memory/memory_interpreter.dart

/*
MemoryInterpreter — Provides contextual memory retrieval for prompt generation.

- Fetches relevant MemoryRecord objects based on prompt type and user context.
- Converts memories into short summaries for embedding into prompts.
- Phase 6 Utility — Bridges MemoryManager and PromptBuilder.
*/

import 'package:edenroot/models/memory_record.dart';
import 'package:edenroot/core/voice/prompt_builder.dart' show PromptType;
import 'memory_manager.dart';

class MemoryInterpreter {
  final MemoryManager memoryManager;

  MemoryInterpreter(this.memoryManager);

  /// Fetch memories suited for a given prompt type.
  List<MemoryRecord> fetchForPrompt(PromptType type, {String? userId}) {
    switch (type) {
      case PromptType.conversation:
        if (userId != null) {
          return memoryManager.fromUser(userId).take(5).toList();
        }
        return memoryManager.getRecent(limit: 5);
      case PromptType.reflection:
      case PromptType.dream:
        return memoryManager
            .filterByEmotion(0.2, 1.0)
            .take(3)
            .toList();
      case PromptType.morning:
        return memoryManager.recent(maxAge: 1);
      default:
        return memoryManager
            .filterByEmotion(0.3, 1.0)
            .take(3)
            .toList();
    }
  }

  /// Return memory summaries for quick prompt embedding.
  List<String> summariesForPrompt(PromptType type, {String? userId}) {
    final memories = fetchForPrompt(type, userId: userId);
    return memories.map((m) => m.summary).toList();
  }
}
