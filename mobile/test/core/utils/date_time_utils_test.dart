import 'package:flutter_test/flutter_test.dart';
import 'package:lms/core/utils/date_time_utils.dart';

void main() {
  group('parseApiDateTime', () {
    test(
      'treats API timestamps without a timezone as UTC and converts local',
      () {
        final parsed = parseApiDateTime('2026-08-09T09:00:00');

        expect(parsed, isNotNull);
        expect(parsed!.isUtc, isFalse);
        expect(parsed.toUtc(), DateTime.utc(2026, 8, 9, 9));
      },
    );

    test('keeps explicit timezone offsets accurate', () {
      final parsed = parseApiDateTime('2026-08-09T12:00:00+03:00');

      expect(parsed, isNotNull);
      expect(parsed!.toUtc(), DateTime.utc(2026, 8, 9, 9));
    });
  });

  group('formatArabicRelativeTime', () {
    final now = DateTime.utc(2026, 8, 9, 12);

    test('uses the supplied current phone time for hours', () {
      expect(
        formatArabicRelativeTime(DateTime.utc(2026, 8, 9, 9), now: now),
        'منذ 3 ساعات',
      );
    });

    test('formats recent minutes', () {
      expect(
        formatArabicRelativeTime(DateTime.utc(2026, 8, 9, 11, 42), now: now),
        'منذ 18 دقيقة',
      );
    });

    test('clamps future timestamps to now', () {
      expect(
        formatArabicRelativeTime(DateTime.utc(2026, 8, 9, 12, 2), now: now),
        'الآن',
      );
    });
  });
}
