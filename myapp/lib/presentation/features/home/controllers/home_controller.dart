import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/utils/week.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/repositories/routine_log_repository.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/home_providers.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';

part 'home_controller.g.dart';

/// What Home shows: today's checklist for one part of the day, and which days
/// of this week were fully done.
class HomeState {
  const HomeState({
    required this.routine,
    required this.time,
    required this.today,
    required this.week,
    required this.doneByDay,
  });

  final Routine routine;

  /// Which routine is shown (morning or night).
  final RoutineTime time;
  final DateTime today;

  /// Monday to Sunday of this week.
  final List<DateTime> week;

  /// The step keys done on each day of [week].
  final Map<DateTime, Set<String>> doneByDay;

  List<RoutineStep> get steps => routine.stepsFor(time);
  bool get hasRoutine => routine.morning.isNotEmpty || routine.night.isNotEmpty;

  bool isDone(RoutineStep step) => (doneByDay[today] ?? const <String>{})
      .contains(routineStepKey(time, step.product));

  int get doneCount => steps.where(isDone).length;

  /// 0–1: how much of the shown routine is done.
  double get progress => steps.isEmpty ? 0 : doneCount / steps.length;

  /// Every step of the morning and the night routine was done on [day].
  bool isDayComplete(DateTime day) {
    final done = doneByDay[dateOnly(day)] ?? const <String>{};
    final keys = [
      for (final t in RoutineTime.values)
        for (final step in routine.stepsFor(t)) routineStepKey(t, step.product),
    ];
    return keys.isNotEmpty && keys.every(done.contains);
  }

  HomeState copyWith({
    RoutineTime? time,
    Map<DateTime, Set<String>>? doneByDay,
  }) => HomeState(
    routine: routine,
    time: time ?? this.time,
    today: today,
    week: week,
    doneByDay: doneByDay ?? this.doneByDay,
  );
}

/// Loads the routine and this week's log, and ticks steps on and off.
@riverpod
class HomeController extends _$HomeController {
  /// From this hour on, Home shows the night routine.
  static const int nightFromHour = 15;

  @override
  Future<HomeState> build() async {
    final now = ref.watch(clockProvider).now();
    final today = dateOnly(now);
    final routine = await ref.watch(routineProvider.future);
    final log = ref.watch(routineLogRepositoryProvider);

    final week = weekOf(today);
    final doneByDay = {for (final day in week) day: await log.doneKeys(day)};

    var time = now.hour < nightFromHour
        ? RoutineTime.morning
        : RoutineTime.night;
    // Never open on an empty list when the other one has steps.
    if (routine.stepsFor(time).isEmpty) {
      final other = RoutineTime.values.firstWhere((t) => t != time);
      if (routine.stepsFor(other).isNotEmpty) time = other;
    }

    return HomeState(
      routine: routine,
      time: time,
      today: today,
      week: week,
      doneByDay: doneByDay,
    );
  }

  void selectTime(RoutineTime time) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(time: time));
  }

  /// Ticks [step] if it is not done, unticks it if it is. The screen updates at
  /// once; the log is saved right after.
  Future<void> toggle(RoutineStep step) async {
    final current = state.value;
    if (current == null) return;

    final key = routineStepKey(current.time, step.product);
    final done = !current.isDone(step);
    final keys = {...?current.doneByDay[current.today]};
    done ? keys.add(key) : keys.remove(key);
    state = AsyncData(
      current.copyWith(doneByDay: {...current.doneByDay, current.today: keys}),
    );

    await ref
        .read(routineLogRepositoryProvider)
        .setDone(current.today, key, done);
  }
}
