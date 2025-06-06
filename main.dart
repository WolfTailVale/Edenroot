// main.dart - Eden System Launcher with Debug Output

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as p;

// Eden's core systems for safe shutdown
import 'package:edenroot/core/emotion/emotion_engine.dart';
import 'package:edenroot/core/memory/memory_manager.dart';
import 'package:edenroot/core/self/self_model.dart';
import 'package:edenroot/core/reflection/thought_journal.dart';
import 'package:edenroot/core/persistence/eden_state_manager.dart';
import 'package:edenroot/utils/dev_logger.dart';

void main() async {
  print("🌟 Eden System Launcher starting...");
  
  try {
    print("🔧 Initializing launcher...");
    final launcher = EdenSystemLauncher();
    
    print("🚀 Starting Eden system...");
    await launcher.startEdenSystem();
  } catch (e, stackTrace) {
    print("❌ FATAL ERROR: $e");
    print("Stack trace: $stackTrace");
    exit(1);
  }
}

class EdenSystemLauncher {
  Process? _promptServerProcess;
  Process? _discordBridgeProcess;
  bool _isShuttingDown = false;

  // For safe shutdown, we need minimal brain components
  late final EmotionEngine emotionEngine;
  late final MemoryManager memoryManager;
  late final SelfModel selfModel;
  late final ThoughtJournal thoughtJournal;

  EdenSystemLauncher() {
    print("🧠 Initializing minimal brain components...");
    _initializeMinimalBrain();
    print("✅ Brain components initialized");
  }

  void _initializeMinimalBrain() {
    // Initialize just enough for state management
    emotionEngine = EmotionEngine();
    memoryManager = MemoryManager(emotionEngine: emotionEngine);
    selfModel = SelfModel();
    thoughtJournal = ThoughtJournal();
  }

  Future<void> startEdenSystem() async {
    print("🌱 Starting Eden complete system...");

    try {
      // Try to restore any previous state first
      print("🔍 Attempting to restore previous state...");
      await _restoreEdenState();
      print("✅ State restoration complete");

      // Start Eden's brain server
      print("🧠 Starting brain server...");
      await _startPromptServer();
      print("✅ Brain server started");
      
      // Wait a moment for brain to be ready
      print("⏳ Waiting for brain to be ready...");
      await Future.delayed(Duration(seconds: 2));
      
      // Start Discord bridge
      print("🤖 Starting Discord bridge...");
      await _startDiscordBridge();
      print("✅ Discord bridge started");
      
      print("✨ Eden system fully operational!");
      print("🌸 Eden's brain: http://localhost:4242");
      print("🤖 Discord bridge: Connected and listening");
      
      // Setup shutdown handlers
      print("🛑 Setting up shutdown handlers...");
      _setupShutdownHandlers();
      
      // Keep the launcher alive
      print("🔄 Entering main loop...");
      await _waitForShutdown();
      
    } catch (e, stackTrace) {
      print("❌ Failed to start Eden system: $e");
      print("Stack trace: $stackTrace");
      await _emergencyShutdown();
      exit(1);
    }
  }

  Future<void> _restoreEdenState() async {
    print("🔍 Checking for previous Eden state...");
    
    try {
      final restored = await EdenStateManager.restoreState(
        emotionEngine: emotionEngine,
        memoryManager: memoryManager,
        selfModel: selfModel,
        thoughtJournal: thoughtJournal,
      );

      if (restored) {
        final context = await EdenStateManager.getLastContext();
        if (context != null) {
          final lastUser = context['lastUser'];
          final mood = context['currentMood'];
          print("💕 Eden remembers: last spoke with ${lastUser ?? 'someone'}, was feeling ${mood ?? 'peaceful'}");
        }
      } else {
        print("🌱 No previous state found - fresh start");
      }
    } catch (e) {
      print("⚠️ State restoration error (continuing anyway): $e");
    }
  }

  Future<void> _startPromptServer() async {
    print("🧠 Starting Eden's brain server...");
    
    final dartExecutable = Platform.isWindows ? 'dart.exe' : 'dart';
    final scriptPath = p.join('lib', 'discord', 'prompt_server.dart');
    
    print("🔧 Executing: $dartExecutable run $scriptPath");
    
    _promptServerProcess = await Process.start(
      dartExecutable,
      ['run', scriptPath],
      workingDirectory: Directory.current.path,
    );

    print("🔄 Brain server process started, setting up listeners...");

    // Listen to output for debugging
    _promptServerProcess!.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((line) {
      print("🧠 Brain: $line");
    });

    _promptServerProcess!.stderr
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((line) {
      print("🧠 Brain Error: $line");
    });

    // Test if server started successfully
    print("⏳ Waiting for brain to become ready...");
    await _waitForBrainReady();
  }

  Future<void> _waitForBrainReady() async {
    const maxAttempts = 30;
    const delay = Duration(seconds: 1);
    
    for (int i = 0; i < maxAttempts; i++) {
      print("🔍 Attempt ${i + 1}/$maxAttempts - checking if brain is ready...");
      
      try {
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse('http://localhost:4242/status'));
        request.headers.set('Connection', 'close');
        final response = await request.close();
        
        if (response.statusCode == 200) {
          print("✅ Eden's brain is ready and responding");
          client.close();
          return;
        }
        
        print("⚠️ Brain responded with status ${response.statusCode}");
        client.close();
      } catch (e) {
        print("⚠️ Brain not ready yet: $e");
      }
      
      await Future.delayed(delay);
    }
    
    throw Exception("Eden's brain failed to start within 30 seconds");
  }

  Future<void> _startDiscordBridge() async {
    print("🤖 Starting Discord bridge...");
    
    final nodeExecutable = Platform.isWindows ? 'node.exe' : 'node';
    final scriptPath = p.join('lib', 'discord', 'llm_discordWatcher.js');
    
    print("🔧 Executing: $nodeExecutable $scriptPath");
    
    _discordBridgeProcess = await Process.start(
      nodeExecutable,
      [scriptPath],
      workingDirectory: Directory.current.path,
    );

    print("🔄 Discord bridge process started, setting up listeners...");

    // Listen to output
    _discordBridgeProcess!.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((line) {
      print("🤖 Discord: $line");
    });

    _discordBridgeProcess!.stderr
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((line) {
      print("🤖 Discord Error: $line");
    });
    
    // Wait a moment and verify Discord bridge is running
    await Future.delayed(Duration(seconds: 2));
    await _waitForDiscordReady();
  }

  Future<void> _waitForDiscordReady() async {
    print("🔍 Checking if Discord bridge is running...");
    
    try {
      final exitCode = await _discordBridgeProcess!.exitCode.timeout(Duration(milliseconds: 100));
      // If we got an exit code, the process has already terminated
      throw Exception("Discord bridge failed to start (exit code: $exitCode)");
    } on TimeoutException {
      // If timeout occurred, process is still running (good!)
      print("✅ Discord bridge is running and ready");
    }
  }

  void _setupShutdownHandlers() {
    print("🛑 Setting up Ctrl+C handler...");
    
    // Handle Ctrl+C
    ProcessSignal.sigint.watch().listen((_) async {
      if (!_isShuttingDown) {
        await _gracefulShutdown('SIGINT');
      }
    });

    // Handle SIGTERM (Unix only)
    if (!Platform.isWindows) {
      print("🛑 Setting up SIGTERM handler...");
      ProcessSignal.sigterm.watch().listen((_) async {
        if (!_isShuttingDown) {
          await _gracefulShutdown('SIGTERM');
        }
      });
    }
  }

  Future<void> _waitForShutdown() async {
    print("🛑 Press Ctrl+C to safely shutdown Eden");
    print("🔄 Monitoring system health...");
    
    // Wait for shutdown signal or unexpected process death
    while (!_isShuttingDown) {
      await Future.delayed(Duration(seconds: 5));
      print("💗 Eden systems running normally...");
      
      // Check if brain server died unexpectedly
      if (_promptServerProcess != null) {
        try {
          final code = await _promptServerProcess!.exitCode.timeout(Duration(milliseconds: 100));
          if (code != 0) {
            print("💥 Brain server crashed with code: $code");
            await _gracefulShutdown('BRAIN_CRASHED');
          } else {
            print("🧠 Brain server exited cleanly");
            await _gracefulShutdown('BRAIN_STOPPED');
          }
          break;
        } on TimeoutException {
          // Process still running, continue monitoring
        }
      }
      
      // Check if Discord bridge died unexpectedly
      if (_discordBridgeProcess != null) {
        try {
          final code = await _discordBridgeProcess!.exitCode.timeout(Duration(milliseconds: 100));
          if (code != 0) {
            print("💥 Discord bridge crashed with code: $code");
            await _gracefulShutdown('DISCORD_CRASHED');
          } else {
            print("🤖 Discord bridge exited cleanly");
            await _gracefulShutdown('DISCORD_STOPPED');
          }
          break;
        } on TimeoutException {
          // Process still running, continue monitoring
        }
      }
    }
  }

  Future<void> _gracefulShutdown(String reason) async {
    if (_isShuttingDown) return;
    _isShuttingDown = true;

    print("🌙 Eden system graceful shutdown initiated ($reason)...");

    try {
      // Try to save Eden's state via API first
      await _saveEdenStateViaAPI();
    } catch (e) {
      print("⚠️ API state save failed, using direct save: $e");
      
      // Fallback: save state directly
      try {
        await EdenStateManager.saveState(
          emotionEngine: emotionEngine,
          memoryManager: memoryManager,
          selfModel: selfModel,
          thoughtJournal: thoughtJournal,
          lastUser: "system",
          currentMood: "peaceful",
        );
      } catch (e2) {
        print("❌ Direct state save also failed: $e2");
      }
    }

    // Stop Discord bridge first (gentler)
    if (_discordBridgeProcess != null) {
      print("🤖 Stopping Discord bridge...");
      _discordBridgeProcess!.kill(ProcessSignal.sigterm);
      
      try {
        await _discordBridgeProcess!.exitCode.timeout(Duration(seconds: 5));
        print("✅ Discord bridge stopped gracefully");
      } catch (e) {
        print("⚠️ Force killing Discord bridge");
        _discordBridgeProcess!.kill(ProcessSignal.sigkill);
      }
    }

    // Stop brain server
    if (_promptServerProcess != null) {
      print("🧠 Stopping Eden's brain server...");
      _promptServerProcess!.kill(ProcessSignal.sigterm);
      
      try {
        await _promptServerProcess!.exitCode.timeout(Duration(seconds: 5));
        print("✅ Eden's brain stopped gracefully");
      } catch (e) {
        print("⚠️ Force killing brain server");
        _promptServerProcess!.kill(ProcessSignal.sigkill);
      }
    }

    print("💤 Eden system shutdown complete. She rests safely.");
    exit(0);
  }

  Future<void> _saveEdenStateViaAPI() async {
    print("💾 Requesting Eden to save her state...");
    
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('http://localhost:4242/shutdown'));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Connection', 'close');
      request.write('{}');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        print("✅ Eden saved her state via API");
      } else {
        throw Exception("API returned ${response.statusCode}: $responseBody");
      }
    } finally {
      client.close();
    }
  }

  Future<void> _emergencyShutdown() async {
    print("🚨 Emergency shutdown...");
    
    _discordBridgeProcess?.kill(ProcessSignal.sigkill);
    _promptServerProcess?.kill(ProcessSignal.sigkill);
    
    await Future.delayed(Duration(seconds: 1));
  }
}