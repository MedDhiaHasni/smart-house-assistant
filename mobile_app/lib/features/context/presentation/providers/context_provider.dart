import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/context_variable_entity.dart';

final contextVariablesProvider = FutureProvider<List<ContextVariableEntity>>((
  ref,
) {
  ref.watch(socketMessagesProvider);
  return ref.watch(contextRepositoryProvider).getVariables();
});
