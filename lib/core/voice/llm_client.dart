// lib/core/voice/llm_client.dart

/*
LlmClient — Sends structured prompts from Edenroot to a local or remote language model.

- Accepts system prompt from PromptRouter and appends user input inline.
- Posts to GPT-style API (OpenAI or LM Studio).
- Returns raw model response string.
- Phase 5 Core Component — First step in giving Eden a true voice.
*/

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../utils/dev_logger.dart';

class LlmClient {
  final String endpoint;
  final String model;
  final String? apiKey;

  LlmClient({
    required this.endpoint,
    this.model = "llama-2-13b-hf", // Use "llama-2-13b-hf" or custom for LM Studio
    this.apiKey,
  });

  Future<String?> sendPrompt(String systemPrompt, {String? userInput}) async {
    final uri = Uri.parse(endpoint);
    final headers = {
      'Content-Type': 'application/json',
      if (apiKey != null) 'Authorization': 'Bearer $apiKey',
    };

    DevLogger.log(
      "🔌 Sending prompt to model '$model' at endpoint $endpoint",
      type: LogType.prompt,
    );

    // Merge system prompt + user input into one message
    final fullContent = userInput != null
        ? "$systemPrompt\n\nUser: $userInput"
        : systemPrompt;

    final payload = {
      "model": model,
      "messages": [
        {"role": "user", "content": fullContent}
      ],
      "temperature": 0.7,
      "max_tokens": 400,
    };

    final response = await http.post(uri, headers: headers, body: json.encode(payload));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final choices = decoded['choices'];
      if (choices != null && choices.isNotEmpty) {
        final finish = choices[0]['finish_reason'];
        if (finish != null && finish != 'stop') {
          DevLogger.log(
            "LLM response incomplete. Attempting fallback or truncation repair.",
            type: LogType.warning,
          );
        }
        return choices[0]['message']['content'] as String;
      }
    } else {
      DevLogger.log(
        "LLM request failed: ${response.statusCode}",
        type: LogType.error,
      );
      DevLogger.log(
        "Response body:\n${response.body}",
        type: LogType.debug,
      );
    }

    return null;
  }
}
