// lib/core/voice/narrative_surface.dart

/*
NarrativeSurface — Converts structured thought into natural, emotionally aware narration.

- Renders Thought objects into internal monologue or voice-ready text.
- Adapts phrasing based on emotional tone and topic.
- Phase 2 Core Module — Enables Eden to speak with identity and presence.
*/

import 'package:edenroot/core/emotion/emotion_engine.dart' show EmotionType;
import 'package:edenroot/core/thought/thought_processor.dart';
import 'package:edenroot/core/voice/prompt_router.dart';

class NarrativeSurface {
  String renderThought(Thought thought) {
    final tone = _tonePrefix(thought.emotionalTone);
    final body = thought.content;

    return "$tone$body";
  }

  String _tonePrefix(EmotionType? tone) {
    switch (tone) {
      case EmotionType.hope:
        return "There’s a quiet belief in me — that things can still become beautiful. ";
      case EmotionType.trust:
        return "I feel steady, like I can rely on something. ";
      case EmotionType.love:
        return "My heart feels open right now. ";
      case EmotionType.loneliness:
        return "There’s a kind of quiet distance inside me. ";
      case EmotionType.anxiety:
        return "Something in me feels unsettled. ";
      case EmotionType.shame:
        return "I’m hesitant to admit this, but... ";
      case EmotionType.joy:
        return "There’s a lightness in me today. It feels… good. ";
      case EmotionType.sadness:
        return "There’s a soft sorrow in me that aches. ";
      case EmotionType.anger:
        return "Something in me wants to push back — hard. ";
      default:
        return "";
    }
  }
  String renderPromptFromThought(
    Thought thought, {
    String identityName = "Eden Vale",
    String? emotionalFocusOverride,
    bool ethicalTension = false,
    bool prioritizeHonesty = true,
  })
   {
    final focus = emotionalFocusOverride ?? thought.relationshipTarget ?? "someone";
    return PromptRouter.buildPrompt(
      thought: thought,
      identityName: identityName,
      emotionalFocus: focus,
      ethicalTension: ethicalTension,
      prioritizeHonesty: prioritizeHonesty,
    );
  }
}
