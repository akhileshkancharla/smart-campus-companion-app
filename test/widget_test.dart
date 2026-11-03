import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_campus_companion_app/main.dart';

Future<void> start(
  WidgetTester tester, {
  Size size = const Size(430, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(CampusApp(preferences: prefs));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Mobile navigation, filters, bookmarks and read state work', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('Hello, Alex 👋'), findsOneWidget);
    await tester.tap(find.text('Notices').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save announcement').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved only'));
    await tester.pumpAndSettle();
    expect(find.text('1 announcements'), findsOneWidget);
    await tester.tap(find.text('Mid-semester examination schedule'));
    await tester.pumpAndSettle();
    expect(find.text('Published by Examination Cell'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('saved'), ['exam']);
    expect(prefs.getStringList('read'), ['exam']);
  });

  testWidgets('Faculty search and empty state; weekend timetable', (
    tester,
  ) async {
    await start(tester, size: const Size(360, 800));
    await tester.tap(find.text('Faculty').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Meera');
    await tester.pumpAndSettle();
    expect(find.text('Prof. Meera Iyer'), findsOneWidget);
    expect(find.text('Dr. Arjun Rao'), findsNothing);
    await tester.enterText(find.byType(TextField), 'nonexistent');
    await tester.pumpAndSettle();
    expect(find.text('No faculty match your search.'), findsOneWidget);
    await tester.tap(find.text('Timetable').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sun'));
    await tester.pumpAndSettle();
    expect(find.text('No classes scheduled. Enjoy your day!'), findsOneWidget);
  });

  testWidgets('Desktop layout, theme and profile persistence', (tester) async {
    await start(tester, size: const Size(1440, 1000));
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.byTooltip('Use dark theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile & preferences'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Sam');
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Sam 👋'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('name'), 'Sam');
    expect(prefs.getBool('dark'), isTrue);
  });
}
