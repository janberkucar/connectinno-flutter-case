import 'package:connectinno_notes/features/notes/models/note.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed local source of truth for the notes list UI.
class NotesLocalDataSource {
  NotesLocalDataSource(this._box);

  final Box<Note> _box;

  List<Note> getAllSorted() {
    final list = _box.values.toList();
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  Future<void> put(Note note) => _box.put(note.id, note);

  Future<void> delete(String id) => _box.delete(id);

  Note? getById(String id) => _box.get(id);

  Future<void> putAll(Iterable<Note> notes) async {
    for (final n in notes) {
      await _box.put(n.id, n);
    }
  }

  List<Note> get all => _box.values.toList();

  /// Called on sign-out to avoid showing another user’s local cache.
  Future<void> clear() async {
    await _box.clear();
  }
}
