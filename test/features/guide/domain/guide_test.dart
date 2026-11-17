import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/guide/domain/guide.dart';

void main() {
  const music = GuideProgress(routineId: 'r1', path: GuidePath.music);
  const difficulties = GuideProgress(
    routineId: 'r1',
    path: GuidePath.difficulties,
  );

  test('the music path starts with the music', () {
    expect(guideSteps(GuidePath.music, freehand: false), [
      GuideStep.addMusic,
      GuideStep.markFirst,
      GuideStep.timeline,
      GuideStep.floorMat,
      GuideStep.playMode,
    ]);
  });

  test('the difficulties path: DB, total, DA, risk, then music', () {
    expect(guideSteps(GuidePath.difficulties, freehand: false), [
      GuideStep.firstDb,
      GuideStep.total,
      GuideStep.firstDa,
      GuideStep.firstRisk,
      GuideStep.addMusic,
      GuideStep.markTimes,
    ]);
  });

  test('freehand has no DA or risk steps', () {
    expect(
      guideSteps(GuidePath.difficulties, freehand: true),
      isNot(contains(anyOf(GuideStep.firstDa, GuideStep.firstRisk))),
    );
  });

  test('steps finish when the routine shows they were done', () {
    expect(music.currentStep(const GuideFacts()), GuideStep.addMusic);
    expect(
      music.currentStep(const GuideFacts(hasMusic: true)),
      GuideStep.markFirst,
    );
    expect(
      music.currentStep(const GuideFacts(hasMusic: true, markedCount: 1)),
      GuideStep.timeline,
    );
    expect(
      difficulties.currentStep(const GuideFacts(dbCount: 1)),
      GuideStep.total,
    );
  });

  test('tap-only steps finish when tapped', () {
    const facts = GuideFacts(hasMusic: true, markedCount: 2);
    final tapped = music.withTapped(GuideStep.timeline);
    expect(tapped.currentStep(facts), GuideStep.floorMat);
    expect(
      tapped.currentStep(
        const GuideFacts(hasMusic: true, markedCount: 2, hasFloorCell: true),
      ),
      GuideStep.playMode,
    );
    expect(
      tapped.withTapped(GuideStep.floorMat).currentStep(facts),
      isNot(GuideStep.floorMat),
    );
  });

  test('steps done out of order are skipped', () {
    final progress = difficulties.withTapped(GuideStep.total);
    expect(
      progress.currentStep(
        const GuideFacts(dbCount: 2, daCount: 1, riskCount: 1),
      ),
      GuideStep.addMusic,
    );
  });

  test('the guide finishes after its last step', () {
    final progress = difficulties
        .withTapped(GuideStep.total)
        .withTapped(GuideStep.markTimes);
    expect(
      progress.currentStep(
        const GuideFacts(hasMusic: true, dbCount: 1, daCount: 1, riskCount: 1),
      ),
      isNull,
    );
  });

  test('round-trips through JSON', () {
    final progress = music.withTapped(GuideStep.timeline);
    expect(GuideProgress.fromJson(progress.toJson()), progress);
  });

  test('ignores JSON it does not understand', () {
    expect(GuideProgress.fromJson('nope'), isNull);
    expect(
      GuideProgress.fromJson({'routineId': 'r1', 'path': 'other'}),
      isNull,
    );
    expect(
      GuideProgress.fromJson({
        'routineId': 'r1',
        'path': 'music',
        'tapped': ['timeline', 'unknown'],
      })!.tapped,
      {GuideStep.timeline},
    );
  });

  test('settings belong to one routine', () {
    const settings = GuideSettings(active: music);
    expect(settings.forRoutine('r1'), music);
    expect(settings.forRoutine('r2'), isNull);
  });
}
