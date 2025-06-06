// lib/thought/thought_object.dart

class ThoughtObject {
  final String emotion;
  final String focus; // Who or what this thought is about
  final String memorySummary;
  final String reflection;

  ThoughtObject({
    required this.emotion,
    required this.focus,
    required this.memorySummary,
    required this.reflection,
  });

  String toPrompt() {
    return "Eden feels $emotion toward $focus. She remembers: $memorySummary. She reflects: $reflection";
  }
}
