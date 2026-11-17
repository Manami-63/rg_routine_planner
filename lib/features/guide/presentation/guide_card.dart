import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/scoring/apparatus.dart';
import '../../routine_editor/domain/routine_timeline.dart';
import '../../routine_editor/presentation/play_mode_screen.dart';
import '../../routine_editor/presentation/routine_screen.dart';
import '../../routines/domain/routine.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/guide.dart';
import 'guide_providers.dart';

/// What the guide card says for each step, and the tab it is done on.
extension GuideStepText on GuideStep {
  RoutineTab get tab => switch (this) {
    GuideStep.firstDb || GuideStep.total => RoutineTab.db,
    GuideStep.firstDa => RoutineTab.da,
    GuideStep.firstRisk => RoutineTab.risks,
    GuideStep.addMusic ||
    GuideStep.markFirst ||
    GuideStep.timeline ||
    GuideStep.floorMat ||
    GuideStep.playMode ||
    GuideStep.markTimes => RoutineTab.music,
  };

  String get title => switch (this) {
    GuideStep.addMusic => 'Add your music',
    GuideStep.markFirst => 'Mark your first move',
    GuideStep.timeline => 'Your timeline',
    GuideStep.floorMat => 'Mark where on the floor',
    GuideStep.playMode => 'Practise in Play mode',
    GuideStep.firstDb => 'Add your first DB',
    GuideStep.total => 'Your provisional total',
    GuideStep.firstDa => 'Add a DA',
    GuideStep.firstRisk => 'Add a risk',
    GuideStep.markTimes => 'Mark the times',
  };

  String get message => switch (this) {
    GuideStep.addMusic =>
      'Tap Add music and choose the file. The app keeps its own copy on '
          'this device.',
    GuideStep.markFirst =>
      'Press play, then tap Add DB, R, DA or S at the bottom when that move starts. '
          'The music pauses so you can choose it. Turn on Choose later to '
          'keep the music playing and choose afterwards.',
    GuideStep.timeline =>
      'Your marks are listed under Timeline. Tap one to jump the music '
          'there, and use − and + to fix its time. A mark that says Not '
          'chosen yet has a Choose button.',
    GuideStep.floorMat =>
      'Drag an Add or Next button at the bottom up onto the floor mat to '
          'mark the time and the place together.',
    GuideStep.playMode =>
      'Play mode shows each move with its symbol and place on the floor '
          'while the music plays.',
    GuideStep.firstDb =>
      'Tap Add element and choose a body difficulty. You can add the rest '
          'in any order.',
    GuideStep.total =>
      'The bar at the bottom adds up DB and DA. It says provisional while '
          'there is a notice to check.',
    GuideStep.firstDa => 'Tap Build a DA, then choose a base and its criteria.',
    GuideStep.firstRisk =>
      'Tap Build a risk, then choose the rotations and criteria.',
    GuideStep.markTimes =>
      'Press play and tap Next DB, R or DA when each one starts. Drag up onto '
          'the floor mat to mark where too. Then try Play mode.',
  };
}

/// What the guide needs to know about [routine].
GuideFacts guideFacts(Routine routine) {
  final entries = routine.timelineEntries;
  return GuideFacts(
    hasMusic: routine.music != null,
    markedCount: entries.length,
    hasFloorCell: entries.any((e) => e.cell != null),
    dbCount: routine.db.elements.where((e) => !e.isPending).length,
    daCount: routine.da.elements.where((e) => !e.isPending).length,
    riskCount: routine.db.risks.where((r) => !r.isPending).length,
    freehand: routine.apparatus == Apparatus.freehand,
  );
}

/// The current step of the routine's guide, shown above the tabs. It says
/// what to do and which tab to open; a step finishes when the routine
/// shows it was done, or when the user taps on. Nothing shows when the
/// routine is not being guided. It folds to one line (e.g. to leave room
/// for the floor mat), and opens again by itself when the next step starts.
class GuideCard extends ConsumerStatefulWidget {
  const GuideCard({super.key, required this.routineId});

  final String routineId;

  @override
  ConsumerState<GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends ConsumerState<GuideCard> {
  /// The step the user folded the card on; a new step shows unfolded.
  GuideStep? _foldedStep;

  String get routineId => widget.routineId;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(
      guideControllerProvider.select((s) => s.forRoutine(routineId)),
    );
    if (progress == null) return const SizedBox.shrink();
    final facts = guideFacts(ref.watch(routineProvider(routineId)));
    final step = progress.currentStep(facts);
    if (step == null) return const SizedBox.shrink();
    final steps = guideSteps(progress.path, freehand: facts.freehand);
    final tabs = DefaultTabController.of(context);
    final controller = ref.read(guideControllerProvider.notifier);

    return ListenableBuilder(
      listenable: tabs,
      builder: (context, _) {
        final onTab = tabs.index == step.tab.index;
        final isLast = step == steps.last;
        return _GuideCardView(
          stepLabel: 'Step ${steps.indexOf(step) + 1} of ${steps.length}',
          title: step.title,
          message: onTab
              ? step.message
              : 'Open the ${step.tab.label} tab to continue.',
          folded: _foldedStep == step,
          onFold: () =>
              setState(() => _foldedStep = _foldedStep == step ? null : step),
          onClose: () => _close(context),
          actions: [
            if (!onTab)
              FilledButton.tonal(
                onPressed: () => tabs.animateTo(step.tab.index),
                child: Text('Go to ${step.tab.label}'),
              )
            else ...[
              if (step == GuideStep.playMode)
                FilledButton.tonal(
                  onPressed: () {
                    controller.tap(routineId, step);
                    PlayModeScreen.show(context, routineId: routineId);
                  },
                  child: const Text('Open Play mode'),
                ),
              if (step == GuideStep.floorMat)
                TextButton(
                  onPressed: () => controller.tap(routineId, step),
                  child: const Text('Skip'),
                ),
              if (step.needsTap)
                FilledButton(
                  onPressed: () {
                    controller.tap(routineId, step);
                    if (isLast) _finished(context);
                  },
                  child: Text(isLast ? 'Done' : 'Got it'),
                ),
            ],
          ],
        );
      },
    );
  }

  void _finished(BuildContext context) => ScaffoldMessenger.of(context)
      .showSnackBar(
        const SnackBar(
          content: Text(
            "You're all set. Turn the guide off in How it works on Home.",
          ),
        ),
      );

  Future<void> _close(BuildContext context) async {
    final turnOff = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close the guide?'),
        content: const Text(
          'You can turn it off for new routines too. It can be turned back '
          'on in How it works on Home.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Turn off'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (turnOff == null) return;
    final controller = ref.read(guideControllerProvider.notifier);
    turnOff ? controller.setEnabled(false) : controller.stop();
  }
}

class _GuideCardView extends StatelessWidget {
  const _GuideCardView({
    required this.stepLabel,
    required this.title,
    required this.message,
    required this.actions,
    required this.folded,
    required this.onFold,
    required this.onClose,
  });

  final String stepLabel;
  final String title;
  final String message;
  final List<Widget> actions;

  /// Only the step's title shows.
  final bool folded;
  final VoidCallback onFold;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Card(
        key: const ValueKey('guide-card'),
        margin: EdgeInsets.zero,
        color: colors.secondaryContainer,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 4, folded ? 0 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: colors.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$stepLabel · $title',
                      maxLines: folded ? 1 : null,
                      overflow: folded ? TextOverflow.ellipsis : null,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: folded ? 'Show the step' : 'Fold the guide',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(folded ? Icons.expand_more : Icons.expand_less),
                    color: colors.onSecondaryContainer,
                    onPressed: onFold,
                  ),
                  IconButton(
                    tooltip: 'Close the guide',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close),
                    color: colors.onSecondaryContainer,
                    onPressed: onClose,
                  ),
                ],
              ),
              if (!folded)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              if (!folded && actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    children: actions,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
