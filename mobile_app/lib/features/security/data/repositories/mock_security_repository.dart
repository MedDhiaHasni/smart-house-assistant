import '../../domain/entities/security_snapshot_entity.dart';
import '../../domain/repositories/security_repository.dart';

class MockSecurityRepository implements SecurityRepository {
  @override
  Future<SecuritySnapshotEntity> getSnapshot() async =>
      const SecuritySnapshotEntity(
        activeMode: 'Away',
        alerts: ['No new alerts'],
        devices: [
          SecurityDeviceEntity(name: 'Front door', status: 'Closed'),
          SecurityDeviceEntity(name: 'Garage', status: 'Motion detected'),
          SecurityDeviceEntity(name: 'Garden camera', status: 'Watching'),
        ],
      );
}
