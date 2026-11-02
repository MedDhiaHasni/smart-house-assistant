import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/mode_state.dart';
import 'modes_controller.dart';

final modesControllerProvider =
    StateNotifierProvider<ModesController, AsyncValue<ModeState>>(
      (ref) => ModesController(ref.watch(modesRepositoryProvider)),
    );
