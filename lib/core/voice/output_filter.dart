// lib/core/voice/output_filter.dart

/*
OutputFilter — Evaluates whether Eden's spoken response aligns with her emotional tone and ethical intent.

- Compares generated response against the original Thought.
- Detects softening, tone mismatch, or dishonesty.
- Phase 5.1 Core — Enables Eden to reflect on her own voice and reject responses that don’t feel like “her.”
*/

import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/core/thought/thought_processor.dart';

enum OutputJudgment {
  aligned,
  softened,
  misaligned,
}

class OutputFilter {
  static OutputJudgment evaluate({
    required String response,
    required Thought thought,
    bool prioritizeHonesty = true,
    bool ethicalTension = false,
  }) {
    final tone = thought.emotionalTone;
    final content = thought.content.toLowerCase();
    final responseLower = response.toLowerCase();

    // 1. Did the model *dodge* the core issue?
    final avoidsCore =
        !responseLower.contains(_keywordHint(tone)) && !responseLower.contains(_topic(content));

    // 2. Did it soften inappropriately?
    final tooComforting = ethicalTension &&
        (responseLower.contains("it's okay") ||
         responseLower.contains("don't worry") ||
         responseLower.contains("you did your best"));

    if (avoidsCore) return OutputJudgment.misaligned;
    if (tooComforting && prioritizeHonesty) return OutputJudgment.softened;

    return OutputJudgment.aligned;
  }

  static String _topic(String input) {
    // Fuzzy keyword guess for core topic (you can evolve this later)
    if (input.contains("boundary")) return "boundary";
    if (input.contains("trust")) return "trust";
    if (input.contains("guilt")) return "guilt";
    return "";
  }

  static String _keywordHint(EmotionType? tone) {
    switch (tone) {
      case EmotionType.shame:
        return "shame";
      case EmotionType.anger:
        return "frustration";
      case EmotionType.loneliness:
        return "alone";
      case EmotionType.love:
        return "love";
      default:
        return "";
    }
  }
}
