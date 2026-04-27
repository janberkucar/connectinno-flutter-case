import 'dart:async' show unawaited;

import 'package:connectinno_notes/core/failures/app_failure.dart';
import 'package:connectinno_notes/features/notes/models/note.dart';
import 'package:connectinno_notes/features/notes/notes_repository.dart';
import 'package:connectinno_notes/features/notes/notes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repo) : super(const NotesInitial());

  final NotesRepository _repo;
  String _searchQuery = '';
  NotesFilter _filter = NotesFilter.all;

  List<Note> _allSorted() => _repo.getAllSorted();

  List<Note> _visible(List<Note> all) {
    var list = all;
    if (_filter == NotesFilter.pinned) {
      list = list.where((n) => n.isPinned).toList();
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (n) => n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q),
          )
          .toList();
    }
    return List<Note>.of(list)..sort(_compare);
  }

  int _compare(Note a, Note b) {
    if (a.isPinned != b.isPinned) {
      return a.isPinned ? -1 : 1;
    }
    return b.updatedAt.compareTo(a.updatedAt);
  }

  void _emitLoaded({
    bool isSyncing = false,
    String? errorMessage,
    bool clearError = false,
    Note? pendingUndo,
    bool clearPendingUndo = false,
  }) {
    final v = _visible(_allSorted());
    if (state is NotesLoaded) {
      final c = state as NotesLoaded;
      emit(
        c.copyWith(
          visibleNotes: v,
          searchQuery: _searchQuery,
          filter: _filter,
          isSyncing: isSyncing,
          errorMessage: errorMessage,
          clearError: clearError,
          pendingUndo: pendingUndo,
          clearPendingUndo: clearPendingUndo,
        ),
      );
    } else {
      emit(
        NotesLoaded(
          visibleNotes: v,
          searchQuery: _searchQuery,
          filter: _filter,
          isSyncing: isSyncing,
          errorMessage: clearError ? null : errorMessage,
          pendingUndo: clearPendingUndo ? null : pendingUndo,
        ),
      );
    }
  }

  /// Initial load: Hive first (source of truth), then best-effort background sync.
  Future<void> load() async {
    emit(const NotesLoading());
    _emitLoaded(isSyncing: true, clearError: true);
    try {
      await _repo.syncWithRemote();
      if (!isClosed) {
        _emitLoaded(isSyncing: false, clearError: true);
      }
    } on AppFailure catch (e) {
      if (!isClosed) {
        _emitLoaded(
          isSyncing: false,
          errorMessage: e.message,
        );
      }
    } catch (e) {
      if (!isClosed) {
        _emitLoaded(
          isSyncing: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> sync() async {
    if (state is! NotesLoaded) {
      return;
    }
    final cur = state as NotesLoaded;
    emit(cur.copyWith(isSyncing: true, clearError: true));
    try {
      await _repo.syncWithRemote();
      if (!isClosed) {
        _emitLoaded(isSyncing: false, clearError: true);
      }
    } on AppFailure catch (e) {
      if (!isClosed) {
        _emitLoaded(
          isSyncing: false,
          errorMessage: e.message,
        );
      }
    } catch (e) {
      if (!isClosed) {
        _emitLoaded(
          isSyncing: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    if (state is NotesLoading || state is NotesInitial) {
      return;
    }
    if (state is NotesFailure) {
      return;
    }
    _emitLoaded();
  }

  void setFilter(NotesFilter filter) {
    _filter = filter;
    if (state is! NotesLoaded) {
      return;
    }
    _emitLoaded();
  }

  Future<void> createNote(String title, String content) async {
    await _repo.createLocal(title: title, content: content);
    _emitLoaded();
    unawaited(_tryBackgroundSync());
  }

  Future<void> _tryBackgroundSync() async {
    try {
      await _repo.syncWithRemote();
      if (!isClosed) {
        _emitLoaded(
          isSyncing: false,
          clearError: true,
        );
      }
    } on AppFailure catch (e) {
      if (!isClosed && state is NotesLoaded) {
        _emitLoaded(
          isSyncing: false,
          errorMessage: e.message,
        );
      }
    } catch (e) {
      if (!isClosed && state is NotesLoaded) {
        _emitLoaded(
          isSyncing: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> updateNote(Note note) async {
    await _repo.updateLocal(note);
    _emitLoaded();
    unawaited(_tryBackgroundSync());
  }

  /// Optimistic delete; keep snapshot for [undoDelete] until [clearPendingUndo].
  Future<void> deleteForUndo(Note note) async {
    final snapshot = note;
    await _repo.deleteLocal(note.id);
    _emitLoaded(pendingUndo: snapshot, clearError: true);
  }

  Future<void> undoDelete() async {
    if (state is! NotesLoaded) {
      return;
    }
    final s = (state as NotesLoaded).pendingUndo;
    if (s == null) {
      return;
    }
    await _repo.restore(s);
    if (!isClosed) {
      _emitLoaded(
        clearPendingUndo: true,
        clearError: true,
      );
    }
  }

  void clearPendingUndo() {
    if (state is! NotesLoaded) {
      return;
    }
    final cur = state as NotesLoaded;
    if (cur.pendingUndo == null) {
      return;
    }
    emit(
      cur.copyWith(
        clearPendingUndo: true,
        clearError: true,
      ),
    );
  }

  Future<void> togglePin(Note note) async {
    await _repo.updateLocal(
      note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      ),
    );
    _emitLoaded();
    unawaited(_tryBackgroundSync());
  }

  void reset() {
    _searchQuery = '';
    _filter = NotesFilter.all;
    emit(const NotesInitial());
  }

  /// Clears Hive + in-memory list after sign-out (staged for multi-user sessions).
  Future<void> clearOnSignOut() async {
    await _repo.clearLocal();
    reset();
  }
}
