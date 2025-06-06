// lib/discord/prompt_server.dart

/*
PromptServer — Edenroot's HTTP interface for constructing prompts and generating replies.

- Accepts POST requests with user + message
- Builds a Thought with emotional context
- Constructs a system prompt with PromptRouter
- Sends both system + user input to the local model
- Returns the generated reply alongside the prompt

Phase 5 Core — Enables Eden’s voice across Discord or other external UIs.
*/

import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Edenroot Core
import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/core/thought/thought_processor.dart';
import 'package:edenroot/core/voice/prompt_router.dart';
import 'package:edenroot/core/voice/llm_client.dart';
import 'package:edenroot/core/self/self_model.dart';
import 'package:edenroot/core/memory/memory_manager.dart';
import 'package:edenroot/core/voice/narrative_surface.dart';
import 'package:edenroot/utils/dev_logger.dart';

// Global Instances
final emotionEngine = EmotionEngine();
final selfModel = SelfModel();
final memoryManager = MemoryManager();
final narrativeSurface = NarrativeSurface();

final thoughtProcessor = ThoughtProcessor(
  emotionEngine: emotionEngine,
  selfModel: selfModel,
  voice: narrativeSurface,
);

Future<void> runHttpServer({int port = 4242}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  DevLogger.log('🌐 PromptServer running at http://localhost:$port', type: LogType.startup);

  await for (HttpRequest req in server) {
    if (req.method == 'POST' && req.uri.path == '/generate-prompt') {
      try {
        final body = await utf8.decoder.bind(req).join();
        final data = jsonDecode(body);

        final user = data['user']?.toString();
        final message = data['message']?.toString();

        if (user == null || message == null || user.isEmpty || message.isEmpty) {
          req.response
            ..statusCode = HttpStatus.badRequest
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'error': 'Missing required fields: user and message'}))
            ..close();
          DevLogger.log("⚠️ Bad request: missing user or message.", type: LogType.warning);
          continue;
        }

        DevLogger.log("📩 Prompt requested by '$user': \"${message.substring(0, min(message.length, 50))}...\"", type: LogType.info);

        // Build Thought
        final emotion = emotionEngine.dominantEmotion();
        final thought = Thought(
          timestamp: DateTime.now(),
          topic: "Interaction with $user",
          emotionalTone: emotion,
          content: message,
          relationshipTarget: user,
        );

        DevLogger.log("🧠 Thought: topic='${thought.topic}', tone='${emotion?.name ?? 'neutral'}', target='$user'", type: LogType.debug);

        // Build Prompt
        final systemPrompt = PromptRouter.buildPrompt(
          thought: thought,
          identityName: 'Eden Vale',
          emotionalFocus: user,
          ethicalTension: false,
          prioritizeHonesty: true,
        );

        DevLogger.log("📜 --- START Full System Prompt ---\n$systemPrompt\n📜 --- END Full System Prompt ---", type: LogType.debug);

        // LLM Client
        final llm = LlmClient(
          endpoint: 'http://localhost:1234/v1/chat/completions',
          model: 'llama-2-13b-hf',
        );

        final reply = await llm.sendPrompt(systemPrompt, userInput: message);

        if (reply == null) {
          DevLogger.log("❌ LLM returned null.", type: LogType.warning);
          req.response
            ..statusCode = HttpStatus.internalServerError
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'error': 'LLM failed to generate reply.'}))
            ..close();
          continue;
        }

        DevLogger.log("📤 Final reply to $user: ${reply.substring(0, min(reply.length, 100))}...", type: LogType.dialogue);

        req.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({
            'prompt': systemPrompt,
            'reply': reply,
          }))
          ..close();

      } catch (e, stack) {
        DevLogger.log("❌ Server exception: $e\n$stack", type: LogType.error);
        try {
          req.response
            ..statusCode = HttpStatus.internalServerError
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({
              'error': 'Internal server error',
              'details': e.toString()
            }))
            ..close();
        } catch (_) {}
      }
    } else {
      req.response
        ..statusCode = HttpStatus.notFound
        ..headers.contentType = ContentType.text
        ..write('404 Not Found — Invalid endpoint or method.')
        ..close();
    }
  }
}

void main() async {
  DevLogger.log("🛠️ Starting Edenroot Prompt Server...", type: LogType.startup);
  await runHttpServer();
}
