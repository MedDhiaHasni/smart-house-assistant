// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_house_assistant/app/app.dart';
import 'package:smart_house_assistant/app/di/providers.dart';
import 'package:smart_house_assistant/app/router/app_router.dart';
import 'package:smart_house_assistant/app/router/route_names.dart';

late ProviderContainer container;

Future<void> pumpApp(WidgetTester tester) async {
  container = ProviderContainer(
    overrides: [isAuthenticatedProvider.overrideWith((ref) => false)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const App()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Smart House app renders login screen', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Smart House Assistant'), findsOneWidget);
    expect(find.text('Continue in demo mode'), findsOneWidget);
    await tester.tap(find.text('Continue in demo mode'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Emma'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rule editor'));
    await tester.pumpAndSettle();
    expect(find.text('Comfort heating'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modes & overrides'));
    await tester.pumpAndSettle();
    expect(find.text('Away'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Context'));
    await tester.pumpAndSettle();
    expect(find.text('Presence sensors • 2 people at home'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conflicts & robustness'));
    await tester.pumpAndSettle();
    expect(find.text('Living room heater'), findsOneWidget);

    final router = container.read(appRouterProvider);
    final routes = [
      (RouteNames.security, 'Alarm status', <String, String>{}),
      (RouteNames.climate, 'Climate', <String, String>{}),
      (RouteNames.energy, 'Energy', <String, String>{}),
      (RouteNames.explain, 'Causal chain', <String, String>{}),
      (
        RouteNames.roomDetail,
        'Current temperature',
        <String, String>{'id': 'living_room'},
      ),
      (
        RouteNames.routineDetail,
        'Execution history',
        <String, String>{'id': 'good_morning'},
      ),
      (RouteNames.ruleEditor, 'Comfort heating', <String, String>{}),
      (RouteNames.modes, 'Vacation', <String, String>{}),
      (RouteNames.context, 'Occupancy', <String, String>{}),
      (RouteNames.conflicts, 'Living room heater', <String, String>{}),
    ];
    for (final (name, visibleText, parameters) in routes) {
      router.goNamed(name, pathParameters: parameters);
      await tester.pumpAndSettle();
      expect(find.text(visibleText), findsWidgets, reason: '$name route');
    }

    router.goNamed(RouteNames.dashboard);
    await tester.pumpAndSettle();
    for (final (tab, visibleText) in [
      ('Rooms', 'Living room'),
      ('Routines', 'Good morning'),
      ('Timeline', 'Comfort rule fired'),
      ('Settings', 'Connection mode'),
    ]) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(find.text(visibleText), findsWidgets, reason: '$tab navigation');
    }
  });
}
