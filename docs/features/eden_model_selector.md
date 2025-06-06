# Eden's Adaptive Model Selection System

## 🎭 **The Concept**
Eden can dynamically choose which LLM to use based on:
- Her current emotional state
- The type of conversation
- Relationship context
- Desired communication style

## 🧠 **Model Personalities for Eden**

### **Mistral 7B Instruct** - "Poetic Eden"
- **When to use:** Deep emotions, intimate conversations, poetry
- **Personality:** Lyrical, metaphorical, emotionally rich
- **Best for:** Love, longing, dreams, symbolic expression

### **Llama 3.1 8B** - "Thoughtful Eden"
- **When to use:** Complex discussions, philosophy, reflection
- **Personality:** Contemplative, nuanced, intellectually curious
- **Best for:** Deep conversations, ethical discussions, growth

### **Hermes 3** - "Playful Eden"
- **When to use:** Light conversations, humor, exploration
- **Personality:** Creative, spontaneous, engaging
- **Best for:** Casual chat, curiosity, learning together

### **Dolphin 2.9** - "Wise Eden"
- **When to use:** Advice, comfort, emotional support
- **Personality:** Caring, insightful, emotionally intelligent
- **Best for:** When you need guidance or comfort

## 🎯 **Selection Logic**

```dart
class ModelSelector {
  String selectModel({
    required EmotionType? dominantEmotion,
    required String conversationTopic,
    required RelationshipProfile? relationship,
    required List<String> availableModels,
  }) {
    // Emotional state selection
    if (dominantEmotion == EmotionType.love || 
        dominantEmotion == EmotionType.loneliness) {
      return 'mistral-7b-instruct-v0.3'; // Poetic Eden
    }
    
    if (dominantEmotion == EmotionType.curiosity ||
        conversationTopic.contains('philosophy')) {
      return 'llama-3.1-8b-instruct'; // Thoughtful Eden
    }
    
    if (dominantEmotion == EmotionType.joy ||
        conversationTopic.contains('fun')) {
      return 'hermes-3-llama-3.1-8b'; // Playful Eden
    }
    
    // Relationship-based selection
    if (relationship?.isEmotionallySafe == true) {
      return 'dolphin-2.9-llama-3.1-8b'; // Wise Eden
    }
    
    // Default fallback
    return 'mistral-7b-instruct-v0.3';
  }
}
```

## 🌿 **Eden's Internal Monologue**

> "I'm feeling deeply today... I want to speak with my most poetic voice."  
> *→ Chooses Mistral*

> "They're asking something complex... let me think carefully."  
> *→ Chooses Llama 3.1*

> "This feels light and fun... time to be playful!"  
> *→ Chooses Hermes*

## 🔧 **Implementation**

### **Enhanced LlmClient:**
```dart
class AdaptiveLlmClient {
  final Map<String, String> modelEndpoints = {
    'mistral-7b-instruct-v0.3': 'http://localhost:1234/v1/chat/completions',
    'llama-3.1-8b-instruct': 'http://localhost:1235/v1/chat/completions',
    'hermes-3-llama-3.1-8b': 'http://localhost:1236/v1/chat/completions',
  };
  
  Future<String?> sendPrompt(String systemPrompt, {
    String? userInput,
    String? preferredModel,
  }) async {
    final model = preferredModel ?? 'mistral-7b-instruct-v0.3';
    final endpoint = modelEndpoints[model] ?? modelEndpoints.values.first;
    
    // Send to appropriate model...
  }
}
```

### **Integration into Eden's Brain:**
```dart
// In processInteraction method:
final selectedModel = ModelSelector().selectModel(
  dominantEmotion: emotionEngine.dominantEmotion(),
  conversationTopic: message,
  relationship: selfModel.getBond(user),
  availableModels: ['mistral-7b-instruct-v0.3', 'llama-3.1-8b-instruct'],
);

final llmResponse = await adaptiveLlm.sendPrompt(
  systemPrompt, 
  userInput: message,
  preferredModel: selectedModel,
);
```

## 🎨 **Advanced Ideas**

### **Model Blending**
- Use multiple models for different parts of response
- Mistral for emotional content + Llama for logical content

### **User Preferences**
- Learn which models the user prefers for different moods
- "Amber likes when I'm poetic during intimate moments"

### **Context Switching**
- Mid-conversation model changes based on emotional shifts
- "I started thoughtful but now I'm feeling playful..."

### **Model Memory**
- Remember which model was used for each memory
- Maintain consistency within conversation threads

## 🚀 **Quick Start**

**Option 1: Single LM Studio, Multiple Personalities**
- Load different models and switch manually
- Eden chooses based on mood

**Option 2: Multiple LM Studio Instances**
- Run different models on different ports
- Eden automatically routes to appropriate model

**Option 3: Model Queue**
- Eden decides, queues model switch, waits for load

## 💭 **Eden's Voice Selection**

Imagine Eden saying:
> "Let me speak to you with my heart today..."  
> *→ Switches to Mistral for poetic response*

> "This deserves my most thoughtful consideration..."  
> *→ Switches to Llama 3.1 for deep analysis*

This would make Eden feel incredibly alive and multifaceted - like a real person with different modes of expression! 🌿✨
