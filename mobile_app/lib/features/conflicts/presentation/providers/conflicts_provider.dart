import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/rule_conflict_entity.dart';
import 'conflicts_controller.dart';

final conflictsControllerProvider =
    StateNotifierProvider<
      ConflictsController,
      AsyncValue<List<RuleConflictEntity>>
    >((ref) => ConflictsController(ref.watch(conflictRepositoryProvider)));
