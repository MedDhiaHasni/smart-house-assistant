import '../entities/context_variable_entity.dart';

abstract interface class ContextRepository {
  Future<List<ContextVariableEntity>> getVariables();
}
