import 'package:rg_routine_planner/features/guide/data/guide_store.dart';
import 'package:rg_routine_planner/features/guide/domain/guide.dart';

class FakeGuideStore implements GuideStore {
  FakeGuideStore([this.saved = const GuideSettings()]);

  GuideSettings saved;

  @override
  Future<GuideSettings> load() async => saved;

  @override
  Future<void> save(GuideSettings settings) async => saved = settings;
}
