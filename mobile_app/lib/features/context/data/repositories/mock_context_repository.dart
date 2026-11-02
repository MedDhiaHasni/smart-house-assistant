import '../../domain/entities/context_variable_entity.dart';
import '../../domain/repositories/context_repository.dart';
import '../datasources/mock_context_data_source.dart';

class MockContextRepository implements ContextRepository {
  MockContextRepository(this._source);

  final MockContextDataSource _source;

  @override
  Future<List<ContextVariableEntity>> getVariables() async =>
      List.unmodifiable(_source.load());
}
