import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';

final explainTraceProvider = FutureProvider<List<String>>((ref) {
  ref.watch(socketMessagesProvider);
  return ref.watch(explainRepositoryProvider).getLatestTrace();
});
