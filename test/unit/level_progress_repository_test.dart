import 'package:flutter_test/flutter_test.dart';
import 'package:gaas/data/repositories/database_service.dart';
import 'package:gaas/data/repositories/level_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LevelProgressRepository Tests', () {
    late LevelProgressRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await DatabaseService.reset();
      repository = LevelProgressRepository();
    });

    test('updateStars unlocks next level if not a chapter boundary', () async {
      const opId = 'math_riddle';
      // Level 1 to 2 transition
      await repository.updateStars(opId, 1, 3, 100);
      
      final nextLevel = await repository.getProgress(opId, 2);
      expect(nextLevel, isNotNull);
      expect(nextLevel!.isUnlocked, isTrue);
    });

    test('updateStars does NOT unlock level 11 if chapter 1 stars < 15', () async {
      const opId = 'math_riddle';
      
      // Complete levels 1-9 with 1 star each (9 stars total)
      for (int i = 1; i <= 9; i++) {
        await repository.updateStars(opId, i, 1, 25);
      }
      
      // Complete level 10 with 3 stars (Total = 12 stars)
      await repository.updateStars(opId, 10, 3, 40);
      
      final nextLevel = await repository.getProgress(opId, 11);
      expect(nextLevel, isNull, reason: 'Level 11 should not be unlocked with only 12 stars');
    });

    test('updateStars unlocks level 11 if chapter 1 stars >= 15', () async {
      const opId = 'math_riddle';
      
      // Complete levels 1-9 with 2 stars each (18 stars total)
      for (int i = 1; i <= 9; i++) {
        await repository.updateStars(opId, i, 2, 35);
      }
      
      // Complete level 10 with 1 star (Total = 19 stars)
      await repository.updateStars(opId, 10, 1, 25);
      
      final nextLevel = await repository.getProgress(opId, 11);
      expect(nextLevel, isNotNull);
      expect(nextLevel!.isUnlocked, isTrue);
    });

    test('updateStars unlocks level 21 if chapter 2 stars >= 15', () async {
      const opId = 'math_riddle';
      
      // Unlock up to level 11 first (cheat a bit by unlocking directly or passing chapter 1)
      for (int i = 1; i <= 10; i++) {
        await repository.updateStars(opId, i, 2, 35);
      }
      
      // Complete levels 11-19 with 2 stars each (18 stars total in Chapter 2)
      for (int i = 11; i <= 19; i++) {
        await repository.updateStars(opId, i, 2, 35);
      }
      
      // Complete level 20 with 1 star (Total = 19 stars in Chapter 2)
      await repository.updateStars(opId, 20, 1, 25);
      
      final nextLevel = await repository.getProgress(opId, 21);
      expect(nextLevel, isNotNull);
      expect(nextLevel!.isUnlocked, isTrue);
    });

    test('updateStars preserves isUnlocked on replay', () async {
      const opId = 'math_riddle';
      
      // Unlock level 2
      await repository.updateStars(opId, 1, 3, 100);
      
      // Replay level 1 with lower score
      await repository.updateStars(opId, 1, 1, 25);
      
      final level1 = await repository.getProgress(opId, 1);
      expect(level1!.stars, 3, reason: 'Stars should be preserved if higher');
      expect(level1.isUnlocked, isTrue);
      
      final level2 = await repository.getProgress(opId, 2);
      expect(level2!.isUnlocked, isTrue, reason: 'Level 2 should remain unlocked');
    });
  });
}
