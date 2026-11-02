import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/energy_summary_entity.dart';

final energySummaryProvider = FutureProvider<EnergySummaryEntity>((ref) {
  ref.watch(socketMessagesProvider);
  return ref.watch(energyRepositoryProvider).getSummary();
});
