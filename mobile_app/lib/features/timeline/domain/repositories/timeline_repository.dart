import '../../data/models/timeline_model.dart';

abstract interface class TimelineRepository {
  Future<List<TimelineEntry>> getTimeline();
}
