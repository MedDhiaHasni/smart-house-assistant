import '../../data/models/dashboard_models.dart';

abstract interface class DashboardRepository {
  Future<DashboardData> getDashboard();
}
