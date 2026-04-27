import 'package:connectinno_notes/core/failures/app_failure.dart';
import 'package:connectinno_notes/features/notes/models/note.dart';
import 'package:equatable/equatable.dart';

enum NotesFilter { all, pinned }

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

final class NotesInitial extends NotesState {
  const NotesInitial();
}

final class NotesLoading extends NotesState {
  const NotesLoading();
}

final class NotesLoaded extends NotesState {
  const NotesLoaded({
    required this.visibleNotes,
    required this.searchQuery,
    required this.filter,
    this.isSyncing = false,
    this.pendingUndo,
    this.errorMessage,
  });

  final List<Note> visibleNotes;
  final String searchQuery;
  final NotesFilter filter;
  final bool isSyncing;
  final Note? pendingUndo;
  final String? errorMessage;

  bool get isEmpty => visibleNotes.isEmpty;

  NotesLoaded copyWith({
    List<Note>? visibleNotes,
    String? searchQuery,
    NotesFilter? filter,
    bool? isSyncing,
    Note? pendingUndo,
    bool clearPendingUndo = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotesLoaded(
      visibleNotes: visibleNotes ?? this.visibleNotes,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingUndo: clearPendingUndo ? null : (pendingUndo ?? this.pendingUndo),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        visibleNotes,
        searchQuery,
        filter,
        isSyncing,
        pendingUndo,
        errorMessage,
      ];
}

final class NotesFailure extends NotesState {
  const NotesFailure(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
