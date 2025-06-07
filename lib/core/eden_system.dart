import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/core/memory/memory_manager.dart';
import 'package:edenroot/core/self/self_model.dart';
import 'package:edenroot/core/reflection/reflection_engine.dart';
import 'package:edenroot/core/thought/thought_processor.dart';
import 'package:edenroot/core/will/free_will_engine.dart';
import 'package:edenroot/core/will/desire_scheduler.dart';
import 'package:edenroot/idle/idle_loop.dart';
import 'package:edenroot/core/grounding/emotional_grounding_engine.dart';

abstract class EdenSystem {
  EmotionEngine get emotionEngine;
  MemoryManager get memoryManager;
  SelfModel get selfModel;
  ReflectionEngine get reflectionEngine;
  ThoughtProcessor get thoughtProcessor;
  FreeWillEngine get freeWillEngine;
  DesireScheduler get desireScheduler;
  IdleLoop get idleLoop;
  EmotionalGroundingEngine get groundingEngine;
}
