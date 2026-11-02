import '../entities/security_snapshot_entity.dart';

abstract interface class SecurityRepository {
  Future<SecuritySnapshotEntity> getSnapshot();
}
