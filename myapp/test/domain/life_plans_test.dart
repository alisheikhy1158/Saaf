// Covers: introducing one new product slowly (patch test, then more often)
// with daily reaction check-ins, and the countdown plan before a big event
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/introduction.dart';
import 'package:saaf/domain/entities/life_event.dart';

void main() {
  final start = DateTime(2026, 10, 1);
  DateTime day(int n) => start.add(Duration(days: n));

  group('introducing a new product', () {
    const intro = Introduction(productName: 'Retinol serum', startedOn: null);
    final started = Introduction(
      productName: 'Retinol serum',
      startedOn: start,
    );

    test('patch test first, then 2 nights a week, every other night, done', () {
      expect(started.stageOn(day(0)), IntroStage.patchTest);
      expect(started.stageOn(day(1)), IntroStage.patchTest);
      expect(started.stageOn(day(2)), IntroStage.twiceAWeek);
      expect(started.stageOn(day(15)), IntroStage.twiceAWeek);
      expect(started.stageOn(day(16)), IntroStage.everyOtherNight);
      expect(started.stageOn(day(30)), IntroStage.done);
      expect(intro.stageOn(day(0)), IntroStage.done);
    });

    test('a strong reaction stops it; a mild one pauses it two days', () {
      final strong = started.withReaction(day(5), Reaction.strong);
      expect(strong.stageOn(day(6)), IntroStage.stopped);
      final mild = started.withReaction(day(5), Reaction.mild);
      expect(mild.stageOn(day(5)), IntroStage.paused);
      expect(mild.stageOn(day(6)), IntroStage.paused);
      expect(mild.stageOn(day(7)), IntroStage.twiceAWeek);
    });

    test('asks once a day', () {
      expect(started.needsCheckIn(day(3)), isTrue);
      final answered = started.withReaction(day(3), Reaction.none);
      expect(answered.needsCheckIn(day(3)), isFalse);
      expect(answered.needsCheckIn(day(4)), isTrue);
      expect(
        started.withReaction(day(3), Reaction.strong).needsCheckIn(day(4)),
        isFalse,
      );
    });

    test('is saved and read back', () {
      final saved = started
          .withReaction(day(2), Reaction.none)
          .withReaction(day(3), Reaction.mild);
      final back = Introduction.decode(saved.encode())!;
      expect(back.productName, 'Retinol serum');
      expect(back.startedOn, start);
      expect(back.stageOn(day(3)), IntroStage.paused);
      expect(Introduction.decode('nonsense'), isNull);
    });
  });

  group('getting ready for an event', () {
    final event = LifeEvent(name: 'My wedding', date: day(60));

    test('the plan changes as the day gets closer', () {
      expect(event.stageOn(day(0)), EventStage.buildRoutine); // 60 days
      expect(event.stageOn(day(10)), EventStage.lastNewProduct); // 50
      expect(event.stageOn(day(35)), EventStage.noNewActives); // 25
      expect(event.stageOn(day(48)), EventStage.nothingNew); // 12
      expect(event.stageOn(day(55)), EventStage.gentleWeek); // 5
      expect(event.stageOn(day(60)), EventStage.today);
      expect(event.stageOn(day(61)), EventStage.over);
      expect(event.daysLeft(day(55)), 5);
    });

    test('new actives are discouraged in the last four weeks', () {
      expect(event.tooCloseForNewProduct(day(10)), isFalse);
      expect(event.tooCloseForNewProduct(day(35)), isTrue);
      expect(event.tooCloseForNewProduct(day(61)), isFalse);
    });

    test('is saved and read back', () {
      final back = LifeEvent.decode(event.encode())!;
      expect(back.name, 'My wedding');
      expect(back.date, day(60));
      expect(LifeEvent.decode('{}'), isNull);
    });
  });
}
