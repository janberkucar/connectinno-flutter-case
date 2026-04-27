import 'dart:async' show unawaited;

import 'package:connectinno_notes/core/failures/app_failure.dart';
import 'package:connectinno_notes/features/notes/models/note.dart';
import 'package:connectinno_notes/features/notes/notes_local_datasource.dart';
import 'package:connectinno_notes/features/notes/notes_remote_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

/// Single seam between UI/state and local + remote sources. Hive is authoritative for reads.
class NotesRepository {
  NotesRepository(
    this._local,
    this._remote,
    this._connectivity,
  ) : _uuid = const Uuid();

  final NotesLocalDataSource _local;
  final NotesRemoteDataSource _remote;
  final Connectivity _connectivity;
  final Uuid _uuid;

  List<Note> getAllSorted() => _local.getAllSorted();

  /// Local lookup by id (for edit screen).
  Note? getById(String id) => _local.getById(id);

  Future<Note> createLocal({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final note = Note(
      id: id,
      title: title,
      content: content,
      isPinned: false,
      createdAt: now,
      updatedAt: now,
    );
    await _local.put(note);
    unawaited(_pushCreateIfOnline(note));
    return note;
  }

  Future<Note> updateLocal(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _local.put(updated);
    unawaited(_pushUpdateIfOnline(updated));
    return updated;
  }

  /// Optimistic local delete. Remote delete is best-effort.
  Future<void> deleteLocal(String id) async {
    await _local.delete(id);
    unawaited(_deleteRemoteIfOnline(id));
  }

  Future<void> restore(Note note) => _local.put(note);

  /// Load from server when online, merge into Hive, then return sorted local view.
  Future<void> syncWithRemote() async {
    if (!await _isOnline()) return;
    try {
      final remote = await _remote.fetchNotes();
      final serverIds = remote.map((e) => e.id).toSet();
      for (final n in remote) {
        await _local.put(n);
      }
      // Push local-only notes (e.g. created offline) to server
      for (final local in _local.all) {
        if (!serverIds.contains(local.id)) {
          try {
            final created = await _remote.createNote(local);
            await _local.put(created);
          } on AppFailure {
            // keep local copy; retry on next sync
          } catch (_) {
            // keep local copy; retry on next sync
          }
        }
      }
    } on AppFailure {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _pushCreateIfOnline(Note note) async {
    if (!await _isOnline()) return;
    try {
      final created = await _remote.createNote(note);
      await _local.put(created);
    } on AppFailure {
      // local remains; sync later
    } catch (_) {
      // best-effort
    }
  }

  Future<void> _pushUpdateIfOnline(Note note) async {
    if (!await _isOnline()) return;
    try {
      final updated = await _remote.updateNote(note);
      await _local.put(updated);
    } on AppFailure {
      // best-effort; local already updated
    } catch (_) {
      // best-effort
    }
  }

  Future<void> _deleteRemoteIfOnline(String id) async {
    if (!await _isOnline()) return;
    try {
      await _remote.deleteNote(id);
    } on AppFailure {
      // best-effort
    } catch (_) {
      // best-effort
    }
  }

  Future<bool> _isOnline() async {
    final r = await _connectivity.checkConnectivity();
    return r.any((c) => c != ConnectivityResult.none);
  }

  Future<void> clearLocal() => _local.clear();
}
