import '../datasources/mock_timeline_data_source.dart';
import '../../domain/repositories/timeline_repository.dart';
import '../models/timeline_model.dart';

class MockTimelineRepository implements TimelineRepository {
  @override
  Future<List<TimelineEntry>> getTimeline() async => smartHomeTimeline();
}
