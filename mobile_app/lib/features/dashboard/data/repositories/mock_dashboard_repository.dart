import '../datasources/mock_dashboard_data_source.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_models.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardData> getDashboard() async => smartHomeDashboard();
}
