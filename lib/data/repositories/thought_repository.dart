import '../models/thought.dart';
import '../services/database_service.dart';

/// Repository interface and implementation for managing [Thought] entities.
class ThoughtRepository {
  final DatabaseService _databaseService;

  ThoughtRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  Future<void> saveThought(Thought thought) async {
    final existing = await _databaseService.getById(thought.id);
    if (existing == null) {
      await _databaseService.insert(thought);
    } else {
      await _databaseService.update(thought);
    }
  }

  Future<List<Thought>> getThoughts({bool newestFirst = true}) async {
    return await _databaseService.getAll(newestFirst: newestFirst);
  }

  Future<Thought?> getThoughtById(String id) async {
    return await _databaseService.getById(id);
  }

  Future<void> deleteThought(String id) async {
    await _databaseService.delete(id);
  }

  Future<void> deleteAllThoughts() async {
    await _databaseService.deleteAll();
  }

  Future<List<Thought>> searchThoughts(
    String query, {
    bool newestFirst = true,
  }) async {
    return await _databaseService.search(query, newestFirst: newestFirst);
  }

  Future<List<Thought>> getFavorites({bool newestFirst = true}) async {
    return await _databaseService.getFavorites(newestFirst: newestFirst);
  }

  Future<void> toggleFavorite(String id, bool currentStatus) async {
    await _databaseService.setFavorite(id, !currentStatus);
  }
}
