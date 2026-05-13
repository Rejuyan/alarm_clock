import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_clock/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: SmartAlarmApp()));

    // Verify that we are on the Alarms screen.
    expect(find.text('Your Alarms'), findsOneWidget);
  });
}
