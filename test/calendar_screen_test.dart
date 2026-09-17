import 'package:flutter_test/flutter_test.dart';
import 'package:ncmt_kripa/screens/calendar_screen.dart';

void main() {
  test('calendar helpers format selected date strings', () {
    final date = DateTime(2026, 9, 17);

    expect(calendarDateKey(date), '2026-09-17');
    expect(calendarMonthLabel(date), 'September 2026');
    expect(calendarDayLabel(date), '17');
  });
}
