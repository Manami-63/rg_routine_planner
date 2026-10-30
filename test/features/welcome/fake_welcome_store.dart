import 'package:rg_routine_planner/features/welcome/data/welcome_store.dart';

class FakeWelcomeStore implements WelcomeStore {
  FakeWelcomeStore([this.seen = 0]);

  int seen;

  @override
  Future<int> seenVersion() async => seen;

  @override
  Future<void> markSeen(int version) async => seen = version;
}
