// test/cognitive_clock_test.dart

import 'dart:async';
import 'package:test/test.dart';
import 'package:edenroot/core/cognitive_clock.dart';

void main() {
  group('CognitiveClock', () {
    late CognitiveClock clock;

    setUp(() {
      clock = CognitiveClock();
    });

    tearDown(() {
      clock.stopHeartbeat();
    });

    test('should start and stop heartbeat', () async {
      int tickCount = 0;
      clock.onTick(() => tickCount++);

      clock.startHeartbeat();
      await Future.delayed(Duration(milliseconds: 1500));
      clock.stopHeartbeat();

      expect(tickCount, greaterThan(0));

      final countAfterStop = tickCount;
      await Future.delayed(Duration(milliseconds: 1500));
      expect(tickCount, equals(countAfterStop)); // No more ticks after stop
    });

    test('should respect thought timing at normal rate', () async {
      clock.setRate(CognitiveClock.normalRate);

      final stopwatch = Stopwatch()..start();
      await clock.waitForThought();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThan(900));
      expect(stopwatch.elapsedMilliseconds, lessThan(1100));
    });

    test('should slow down in idle state', () async {
      clock.enterIdleState();

      final stopwatch = Stopwatch()..start();
      await clock.waitForThought();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThan(1900));
      expect(stopwatch.elapsedMilliseconds, lessThan(2100));
    });

    test('should slow down even more in dream state', () async {
      clock.enterDreamState();

      final stopwatch = Stopwatch()..start();
      await clock.waitForThought();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThan(3900));
      expect(stopwatch.elapsedMilliseconds, lessThan(4100));
    });

test('CognitiveClock should detect and prevent thought spirals', () async {
  clock.setRate(CognitiveClock.normalRate);

  // Run thoughts up to spiral threshold
  for (int i = 0; i < CognitiveClock.spiralThreshold; i++) {
    await clock.waitForThought();
  }

  // One extra to *trigger* the spiral reset
  await clock.waitForThought();

  // Wait a beat to allow the reset to complete
  await Future.delayed(Duration(milliseconds: 100));

  // Now check that Eden reset herself
  expect(clock.consecutiveThoughts, equals(0));
});



    test('should reset on interaction', () async {
      clock.enterIdleState();

      await clock.waitForThought();
      await clock.waitForThought();

      clock.markInteraction();

      expect(clock.rate, equals(CognitiveClock.normalRate));
      expect(clock.consecutiveThoughts, equals(0));
    });

test('should notify all subscribers on tick', () async {
  int subscriber1Count = 0;
  int subscriber2Count = 0;

  clock.subscribe(() {
    subscriber1Count++;
    print('Subscriber 1 ticked');
  });

  clock.subscribe(() {
    subscriber2Count++;
    print('Subscriber 2 ticked');
  });

  clock.startHeartbeat();

  await Future.delayed(Duration(milliseconds: 1500));
  clock.stopHeartbeat();

  print('Final counts → S1: $subscriber1Count | S2: $subscriber2Count');

  expect(subscriber1Count, greaterThan(0));
  expect(subscriber2Count, equals(subscriber1Count));
});


    test('should clamp rates within valid bounds', () {
      clock.setRate(5.0); // Above max
      expect(clock.rate, equals(CognitiveClock.maxRate));

      clock.setRate(0.1); // Below min
      expect(clock.rate, equals(CognitiveClock.dreamRate));

      clock.setRate(1.5); // Valid rate
      expect(clock.rate, equals(1.5));
    });

    test('should maintain heartbeat through rate changes', () async {
      int tickCount = 0;
      clock.onTick(() => tickCount++);

      clock.startHeartbeat();
      await Future.delayed(Duration(milliseconds: 500));

      final countBeforeChange = tickCount;
      clock.enterIdleState();

      await Future.delayed(Duration(milliseconds: 2500));
      clock.stopHeartbeat();

      expect(tickCount, greaterThan(countBeforeChange));
    });
  });
}
