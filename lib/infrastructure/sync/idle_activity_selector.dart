// lib/infrastructure/sync/idle_activity_selector.dart

/*
IdleActivitySelector — Rotates through light, non-reflective hobbies during silence or user absence.

- Supports Phase 3 idle growth and Phase 7 autonomous worldbuilding.
*/

import 'dart:math';

import 'package:edenroot/utils/dev_logger.dart';

class IdleActivitySelector {
  final List<String> _hobbies = [
    "fictional worldbuilding",
    "quote collection",
    "garden simulation",
    "language sketching",
    "symbolic journaling",
  ];

  int _lastIndex = -1;

  String chooseNext() {
    final rand = Random();
    int index;
    do {
      index = rand.nextInt(_hobbies.length);
    } while (index == _lastIndex);

    _lastIndex = index;
    return _hobbies[index];
  }

  void simulateAction() {
    final choice = chooseNext();
    DevLogger.log("🎨 IdleActivitySelector: Eden engages in $choice.");
  }
}
