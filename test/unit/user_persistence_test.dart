import 'package:flutter_test/flutter_test.dart';
import 'package:gaas/data/models/user_session.dart';
import 'package:gaas/data/repositories/database_service.dart';
import 'package:gaas/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('User Persistence Tests', () {
    late UserRepository userRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await DatabaseService.reset();
      userRepository = UserRepository();
    });

    test('updateUserSession saves unlockedAvatars list correctly', () async {
      final user = UserSession(
        name: 'Test Player',
        totalPoints: 1000,
        unlockedAvatars: ['circle', 'square'],
      );

      await userRepository.updateUserSession(user);

      final savedUser = await userRepository.getUserSession();
      expect(savedUser, isNotNull);
      expect(savedUser!.name, 'Test Player');
      expect(savedUser.unlockedAvatars, containsAll(['circle', 'square']));
      expect(savedUser.unlockedAvatars!.length, 2);
    });

    test('Persistence handles empty unlockedAvatars list', () async {
      final user = UserSession(
        name: 'Empty List Player',
        unlockedAvatars: [],
      );

      await userRepository.updateUserSession(user);

      final savedUser = await userRepository.getUserSession();
      expect(savedUser!.unlockedAvatars, isEmpty);
    });

    test('Persistence handles null unlockedAvatars list', () async {
       final user = UserSession(
        name: 'Null List Player',
        unlockedAvatars: null,
      );

      await userRepository.updateUserSession(user);

      final savedUser = await userRepository.getUserSession();
      expect(savedUser!.unlockedAvatars, isNull);
    });
  });
}
