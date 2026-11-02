import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/security_snapshot_entity.dart';

final securitySnapshotProvider = FutureProvider<SecuritySnapshotEntity>((ref) {
  ref.watch(socketMessagesProvider);
  return ref.watch(securityRepositoryProvider).getSnapshot();
});
