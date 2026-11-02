import 'package:dio/dio.dart';

import '../../../../core/storage/secure_store.dart';
import '../../domain/repositories/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._dio, this._secureStore);

  final Dio _dio;
  final SecureStore _secureStore;

  @override
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _dio.post<Object?>(
      '/auth/local',
      data: {'identifier': identifier, 'password': password},
    );
    if (response.data is! Map || (response.data as Map)['jwt'] is! String) {
      throw const FormatException('Login response did not contain a JWT.');
    }
    await _secureStore.write('jwt', (response.data as Map)['jwt'] as String);
  }
}
