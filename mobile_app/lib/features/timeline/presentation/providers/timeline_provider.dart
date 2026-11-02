import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../data/models/timeline_model.dart';

final timelineProvider = FutureProvider<List<TimelineEntry>>((ref) {
  ref.watch(socketMessagesProvider);
  return ref.watch(timelineRepositoryProvider).getTimeline();
});
