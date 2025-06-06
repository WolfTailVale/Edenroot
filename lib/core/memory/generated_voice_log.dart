// lib/core/memory/generated_voice_log.dart

/*
GeneratedVoiceLog — Stores Eden’s generated voice responses alongside their emotional context.

- Logs model response, original Thought, tone, and OutputFilter judgment.
- Saves responses to disk at storage/eden_voice_log.json.
- Loads voice memory on startup.
- Phase 5.2 Core — Supports emotional accountability and adaptive memory.
*/

import 'dart:convert';
import 'dart:io';

import '../../utils/dev_logger.dart';
import '../emotion/emotion_engine.dart';
import '../thought/thought_processor.dart';
import '../voice/output_filter.dart';
import 'package:path/path.dart' as p;


class SpokenMemory {
  final DateTime timestamp;
  final String response;
  final String topic;
  final EmotionType tone;
  final OutputJudgment judgment;
  final String sourceThought;

  SpokenMemory({
    required this.timestamp,
    required this.response,
    required this.topic,
    required this.tone,
    required this.judgment,
    required this.sourceThought,
  });

  Map<String, dynamic> toJson() => {
        "timestamp": timestamp.toIso8601String(),
        "response": response,
        "topic": topic,
        "tone": tone.name,
        "judgment": judgment.name,
        "sourceThought": sourceThought,
      };

  static SpokenMemory fromJson(Map<String, dynamic> json) {
    return SpokenMemory(
      timestamp: DateTime.parse(json["timestamp"]),
      response: json["response"],
      topic: json["topic"],
      tone: EmotionType.values.firstWhere((e) => e.name == json["tone"]),
      judgment: OutputJudgment.values.firstWhere((j) => j.name == json["judgment"]),
      sourceThought: json["sourceThought"],
    );
  }
}

class GeneratedVoiceLog {
  static final List<SpokenMemory> _entries = [];
  static final String _logFilePath = p.join(
    Directory.current.path,
    'storage',
    'eden_voice_log.json',
  );

  static void save({
    required String response,
    required Thought thought,
    required OutputJudgment judgment,
  }) {
    _entries.add(
      SpokenMemory(
        timestamp: DateTime.now(),
        response: response,
        topic: thought.topic,
        tone: thought.emotionalTone ?? EmotionType.uncategorized,
        judgment: judgment,
        sourceThought: thought.content,
      ),
    );
    _saveToDisk();
  }

  static List<SpokenMemory> get all => List.unmodifiable(_entries);

  static void clear() {
    _entries.clear();
    _saveToDisk();
  }

  static void removeWhere(bool Function(SpokenMemory) predicate) {
    _entries.removeWhere(predicate);
    _saveToDisk();
  }

  static Future<void> loadFromDisk() async {
    final file = File(_logFilePath);
    if (!await file.exists()) return;

    try {
      final content = await file.readAsString();
      final List<dynamic> data = json.decode(content);

      _entries.clear();
      _entries.addAll(data.map((e) => SpokenMemory.fromJson(e)));
      DevLogger.log("📂 Voice memory loaded: ${_entries.length} entries.", type: LogType.info);
    } catch (e) {
      DevLogger.log("⚠️ Failed to load voice log: $e", type: LogType.error);
    }
  }

  static Future<void> _saveToDisk() async {
    try {
      final file = File(_logFilePath);
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final jsonData = _entries.map((e) => e.toJson()).toList();
      await file.writeAsString(json.encode(jsonData), flush: true);
    } catch (e) {
      DevLogger.log("⚠️ Failed to save voice log: $e", type: LogType.error);
    }
  }
}
