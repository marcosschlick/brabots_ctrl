import 'package:ctrl/widgets/direction_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pumpButton(WidgetTester tester, List<String> events) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DirectionButton(
              onPressed: () => events.add('down'),
              onReleased: () => events.add('release'),
              child: const Text('F'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('calls release after pointer up', (tester) async {
    final events = <String>[];
    await pumpButton(tester, events);

    final center = tester.getCenter(find.byType(DirectionButton));
    final gesture = await tester.startGesture(center);
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(events, ['down', 'release']);
  });

  testWidgets('calls release after pointer cancel', (tester) async {
    final events = <String>[];
    await pumpButton(tester, events);

    final center = tester.getCenter(find.byType(DirectionButton));
    final gesture = await tester.startGesture(center);
    await tester.pump();
    await gesture.cancel();
    await tester.pump();

    expect(events, ['down', 'release']);
  });

  testWidgets('ignores secondary pointers until active pointer releases', (
    tester,
  ) async {
    final events = <String>[];
    await pumpButton(tester, events);

    final center = tester.getCenter(find.byType(DirectionButton));
    final firstGesture = await tester.startGesture(center, pointer: 1);
    await tester.pump();

    final secondGesture = await tester.startGesture(center, pointer: 2);
    await tester.pump();
    await secondGesture.up();
    await tester.pump();

    expect(events, ['down']);

    await firstGesture.up();
    await tester.pump();

    expect(events, ['down', 'release']);
  });
}
