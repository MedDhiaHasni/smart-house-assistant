import '../../domain/repositories/explain_repository.dart';

class MockExplainRepository implements ExplainRepository {
  @override
  Future<List<String>> getLatestTrace() async => const [
    '05:59 • Trigger: bedroom window opened',
    'Condition: comfort rule active and someone at home',
    'Exception: heating blocked because window open',
    'Action skipped: no heat increase at 06:00',
    'Result: rule stayed robust and safe',
  ];
}
