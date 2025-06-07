# Memory Interpreter

The memory interpreter provides a thin layer between the prompt builder and the
memory store. It selects memories for a given prompt type and user context so
that prompts can stay concise while still drawing from meaningful experiences.

## Capabilities
- Fetches memories from `MemoryManager` based on `PromptType`.
- Offers quick summaries for embedding directly in prompts.
- Centralises memory selection logic so future refinement happens in one place.

## Usage
The `PromptBuilder` now calls `system.memoryInterpreter.fetchForPrompt` instead
of querying the `MemoryManager` directly. This keeps prompt generation focused
on interpretation rather than raw retrieval.
