import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_house_assistant/features/conflicts/data/repositories/remote_conflict_repository.dart';
import 'package:smart_house_assistant/features/context/data/repositories/remote_context_repository.dart';
import 'package:smart_house_assistant/features/dashboard/data/repositories/remote_dashboard_repository.dart';
import 'package:smart_house_assistant/features/energy/data/repositories/remote_energy_repository.dart';
import 'package:smart_house_assistant/features/explain/data/repositories/remote_explain_repository.dart';
import 'package:smart_house_assistant/features/modes/data/repositories/remote_modes_repository.dart';
import 'package:smart_house_assistant/features/modes/domain/entities/mode_state.dart';
import 'package:smart_house_assistant/features/rooms/data/repositories/remote_room_repository.dart';
import 'package:smart_house_assistant/features/routines/data/repositories/remote_routine_repository.dart';
import 'package:smart_house_assistant/features/rules/data/repositories/remote_rule_repository.dart';
import 'package:smart_house_assistant/features/security/data/repositories/remote_security_repository.dart';
import 'package:smart_house_assistant/features/timeline/data/repositories/remote_timeline_repository.dart';

void main() {
  const apiUrl = String.fromEnvironment('LIVE_TEST_API_URL');

  test(
    'remote repositories parse the running Strapi v5 responses',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiUrl));
      final routines = RemoteRoutineRepository(dio);
      final results = await Future.wait([
        RemoteRuleRepository(dio).getRules(),
        RemoteContextRepository(dio).getVariables(),
        RemoteModesRepository(dio).load(),
        RemoteConflictRepository(dio).getConflicts(),
        RemoteRoomRepository(dio).getRooms(),
        routines.getRoutines(),
        RemoteTimelineRepository(dio).getTimeline(),
        RemoteDashboardRepository(dio, routines).getDashboard(),
        RemoteEnergyRepository(dio).getSummary(),
        RemoteSecurityRepository(dio).getSnapshot(),
        RemoteExplainRepository(dio).getLatestTrace(),
      ]);

      expect(results[0], isNotEmpty);
      expect(results[1], isNotEmpty);
      expect((results[2] as ModeState).availableModes, isNotEmpty);
      expect(results[4], isNotEmpty);
      expect(results[5], isNotEmpty);
      expect(results[6], isNotEmpty);
      expect(results[7], isNotNull);
      expect(results[8], isNotNull);
      expect(results[9], isNotNull);
      expect(results[10], isNotEmpty);
    },
    skip: apiUrl.isEmpty
        ? 'Set LIVE_TEST_API_URL to run against a live Strapi backend.'
        : false,
  );
}
