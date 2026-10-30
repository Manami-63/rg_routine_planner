import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/welcome/data/welcome_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const store = SharedPreferencesWelcomeStore();

  test('a new install needs the welcome screen', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await store.seenVersion(), 0);
    expect(await needsWelcome(store), isTrue);
  });

  test('once seen, the welcome screen is not needed', () async {
    SharedPreferences.setMockInitialValues({});
    await store.markSeen(welcomeVersion);
    expect(
      (await SharedPreferences.getInstance()).getInt('welcome_version'),
      welcomeVersion,
    );
    expect(await needsWelcome(store), isFalse);
  });

  test('an older version shows the welcome screen again', () async {
    SharedPreferences.setMockInitialValues({
      'welcome_version': welcomeVersion - 1,
    });
    expect(await needsWelcome(store), isTrue);
  });
}
