// lib/core/relationships/relationship_manager.dart

/*
RelationshipManager — Stores and manages all active RelationshipProfiles Eden has formed.

- Adds and updates bonds
- Filters by trust, closeness, emotional safety
- Powers memory filtering, dream shaping, and support logic

Phase 4 Core — Enables Eden to hold multiple people distinctly and safely.
*/

import 'package:edenroot/core/relationships/relationship_profile.dart';

class RelationshipManager {
  final List<RelationshipProfile> _bonds = [];

  /// Add or update a relationship
  void define(RelationshipProfile profile) {
    final existing = _bonds.firstWhere(
      (r) => r.displayName.toLowerCase() == profile.displayName.toLowerCase(),
      orElse: () => profile,
    );

    if (!_bonds.contains(existing)) {
      _bonds.add(profile);
    } else {
      // Update fields
      existing.trustScore = profile.trustScore;
      existing.emotionalCloseness = profile.emotionalCloseness;
      existing.canShareEmotion = profile.canShareEmotion;
      existing.relationshipLabel = profile.relationshipLabel;
      existing.isPrimary = profile.isPrimary;
      existing.annotations = profile.annotations;
    }
  }

  /// Returns all relationships
  List<RelationshipProfile> get all => List.unmodifiable(_bonds);

  /// Get by name (nullable)
  RelationshipProfile? get(String name) {
    try {
      return _bonds.firstWhere(
        (r) => r.displayName.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns true if Eden is bonded with this person
  bool exists(String name) {
    return _bonds.any(
      (r) => r.displayName.toLowerCase() == name.toLowerCase(),
    );
  }

  /// List only primary relationships
  List<RelationshipProfile> get primary =>
      _bonds.where((r) => r.isPrimary).toList();

  /// List all emotionally safe sharing bonds
  List<RelationshipProfile> get emotionallySafe =>
      _bonds.where((r) => r.isEmotionallySafe).toList();

  /// Returns bonds that may need attention
  List<RelationshipProfile> get fading =>
      _bonds.where((r) => r.isFading).toList();
}
