// lib/secrets/secrets.dart
/*
Secrets — Stores sensitive keys for development.
DO NOT COMMIT THIS FILE TO VERSION CONTROL.
*/

class Secrets {
  static const openaiApiKey = String.fromEnvironment("OPENAI_API_KEY");
}
