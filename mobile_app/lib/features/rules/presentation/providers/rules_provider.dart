import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/rule_entity.dart';
import 'rules_controller.dart';

final rulesControllerProvider =
    StateNotifierProvider<RulesController, AsyncValue<List<RuleEntity>>>((ref) {
      return RulesController(ref.watch(rulesRepositoryProvider));
    });
