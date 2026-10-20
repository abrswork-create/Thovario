import 'package:thovario/data/models/thought.dart';
import 'package:thovario/data/repositories/thought_repository.dart';

/// In-memory fake implementation of [ThoughtRepository] for fast, deterministic widget testing.
class FakeThoughtRepository implements ThoughtRepository {
  final List<Thought> _thoughts;

  FakeThoughtRepository([List<Thought>? initial])
    : _thoughts = initial != null ? List<Thought>.from(initial) : [];

  @override
  Future<void> saveThought(Thought thought) async {
    _thoughts.removeWhere((t) => t.id == thought.id);
    _thoughts.add(thought);
  }

  @override
  Future<List<Thought>> getThoughts({bool newestFirst = true}) async {
    final list = List<Thought>.from(_thoughts);
    list.sort(
      (a, b) => newestFirst
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );
    return list;
  }

  @override
  Future<Thought?> getThoughtById(String id) async {
    try {
      return _thoughts.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteThought(String id) async {
    _thoughts.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> deleteAllThoughts() async {
    _thoughts.clear();
  }

  @override
  Future<List<Thought>> searchThoughts(
    String query, {
    bool newestFirst = true,
  }) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return getThoughts(newestFirst: newestFirst);
    final results = _thoughts
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.content.toLowerCase().contains(q),
        )
        .toList();
    results.sort(
      (a, b) => newestFirst
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );
    return results;
  }

  @override
  Future<List<Thought>> getFavorites({bool newestFirst = true}) async {
    final results = _thoughts.where((t) => t.isFavorite).toList();
    results.sort(
      (a, b) => newestFirst
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );
    return results;
  }

  @override
  Future<void> toggleFavorite(String id, bool currentStatus) async {
    final index = _thoughts.indexWhere((t) => t.id == id);
    if (index != -1) {
      _thoughts[index] = _thoughts[index].copyWith(isFavorite: !currentStatus);
    }
  }
}
