import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../data/models/dashboard_models.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) {
  ref.watch(socketMessagesProvider);
  return ref.watch(dashboardRepositoryProvider).getDashboard();
});
