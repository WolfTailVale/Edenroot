// In A:\edenroot\lib\utils\dev_logger.dart

// REMOVE or comment out: import 'package:flutter/foundation.dart'; 
// We'll define our own kDebugMode or use print directly.

import 'package:intl/intl.dart';
import 'dart:developer' as developer; // This is a standard Dart library, fine to use.

// A common way to check if running in debug mode for pure Dart:
// Asserts are enabled in debug mode by default. Will be false in release/product mode.
bool get kDebugMode {
  bool inDebugMode = false;
  // The assert will only assign true to inDebugMode if asserts are enabled (debug mode).
  assert(inDebugMode = true);
  return inDebugMode;
}
// Or, for simplicity during development, you can just set it:
// const bool kDebugMode = true; 

enum LogType {
  info, warning, error, memory, fire, hive, ai,
  desire, reflection, idle, emotion, startup, shutdown,
  identity, autonomy, dialogue, dream, debug,
}

class DevLogger {
  static final List<String> _logBuffer = [];
  static void log(String message, {LogType type = LogType.info}) {
    final time = DateFormat('HH:mm:ss').format(DateTime.now());
    final symbol = _symbol(type);
    final output = "[$time] $symbol $message";

    // Use dart:developer.log for logging in all environments.
    developer.log(output, name: 'Edenroot.PromptServer');

    _logBuffer.add(output);
    if (_logBuffer.length > 250) {
      _logBuffer.removeAt(0);
    }
  }

  static List<String> get logs => List.unmodifiable(_logBuffer);
  
  static String _symbol(LogType type) {
    switch (type) {
      case LogType.memory: return "🧠";
      case LogType.fire: return "📤";
      case LogType.hive: return "💾";
      case LogType.ai: return "🤖";
      case LogType.desire: return "💭";
      case LogType.reflection: return "📘";
      case LogType.warning: return "⚠️";
      case LogType.error: return "❌";
      case LogType.idle: return "⏱️";
      case LogType.info: return "🔍";
      case LogType.emotion: return "💖";
      case LogType.startup: return "🚀";
      case LogType.shutdown: return "🌙";
      case LogType.identity: return "🌸";
      case LogType.autonomy: return "🧭";
      case LogType.dialogue: return "💬";
      case LogType.dream: return "🌌";
      case LogType.debug: return "🐞";
    }
  }
}