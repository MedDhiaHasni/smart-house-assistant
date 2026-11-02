abstract interface class ExplainRepository {
  Future<List<String>> getLatestTrace();
}
