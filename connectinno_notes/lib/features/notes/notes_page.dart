import 'package:connectinno_notes/app/theme/app_colors.dart';
import 'package:connectinno_notes/app/theme/app_spacing.dart';
import 'package:connectinno_notes/features/auth/auth_cubit.dart';
import 'package:connectinno_notes/features/notes/models/note.dart';
import 'package:connectinno_notes/features/notes/notes_cubit.dart';
import 'package:connectinno_notes/features/notes/notes_state.dart';
import 'package:connectinno_notes/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<NotesCubit>().load();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<NotesCubit, NotesState>(
      listenWhen: (NotesState p, NotesState c) {
        if (c is! NotesLoaded) {
          return false;
        }
        if (c.pendingUndo == null) {
          return false;
        }
        if (p is NotesLoaded) {
          return p.pendingUndo != c.pendingUndo;
        }
        return true;
      },
      listener: (BuildContext context, NotesState state) {
        if (state is! NotesLoaded) {
          return;
        }
        if (state.pendingUndo == null) {
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.noteDeleted),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: l10n.undo,
                onPressed: () {
                  context.read<NotesCubit>().undoDelete();
                },
              ),
            ),
          ).closed.then((_) {
            if (context.mounted) {
              context.read<NotesCubit>().clearPendingUndo();
            }
          });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navNotes),
          actions: [
            BlocBuilder<NotesCubit, NotesState>(
              buildWhen: (a, b) => a is NotesLoaded && b is NotesLoaded,
              builder: (BuildContext context, NotesState s) {
                if (s is! NotesLoaded) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: s.isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  tooltip: 'Sync',
                  onPressed: s.isSyncing
                      ? null
                      : () => context.read<NotesCubit>().sync(),
                );
              },
            ),
            IconButton(
              tooltip: l10n.navLogout,
              onPressed: () async {
                await context.read<NotesCubit>().clearOnSignOut();
                if (context.mounted) {
                  await context.read<AuthCubit>().signOut();
                }
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (BuildContext context, NotesState state) {
            if (state is NotesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is NotesFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(state.failure.message, textAlign: TextAlign.center),
                ),
              );
            }
            if (state is NotesLoaded) {
              return _NotesBody(
                l10n: l10n,
                search: _search,
                state: state,
              );
            }
            return Center(child: Text(l10n.loading));
          },
        ),
        floatingActionButton: BlocBuilder<NotesCubit, NotesState>(
          buildWhen: (p, c) => c is NotesLoaded,
          builder: (BuildContext context, NotesState s) {
            if (s is! NotesLoaded) {
              return const SizedBox.shrink();
            }
            return FloatingActionButton(
              onPressed: () => context.push('/notes/new'),
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

class _NotesBody extends StatelessWidget {
  const _NotesBody({
    required this.l10n,
    required this.search,
    required this.state,
  });

  final AppLocalizations l10n;
  final TextEditingController search;
  final NotesLoaded state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.isSyncing) const LinearProgressIndicator(minHeight: 2),
        if (state.errorMessage != null)
          Material(
            color: AppColors.pinned,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: search,
            onChanged: (v) => context.read<NotesCubit>().setSearchQuery(v),
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Wrap(
            spacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: Text(l10n.filterAll),
                selected: state.filter == NotesFilter.all,
                onSelected: (_) => context.read<NotesCubit>().setFilter(NotesFilter.all),
              ),
              ChoiceChip(
                label: Text(l10n.filterPinned),
                selected: state.filter == NotesFilter.pinned,
                onSelected: (_) => context.read<NotesCubit>().setFilter(NotesFilter.pinned),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.emptyNotesTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.emptyNotesBody,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
                  itemCount: state.visibleNotes.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (BuildContext context, int i) {
                    final note = state.visibleNotes[i];
                    return _NoteTile(
                      key: ValueKey<String>(note.id),
                      l10n: l10n,
                      note: note,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    super.key,
    required this.l10n,
    required this.note,
  });

  final AppLocalizations l10n;
  final Note note;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.jm().format(note.updatedAt);
    return Card(
      child: ListTile(
        onTap: () => context.push('/notes/${note.id}'),
        tileColor: note.isPinned ? AppColors.pinned : null,
        title: Text(
          note.title.isEmpty ? l10n.noteTitle : note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$time · ${note.content}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: note.isPinned ? l10n.noteUnpin : l10n.notePin,
              onPressed: () => context.read<NotesCubit>().togglePin(note),
              icon: Icon(
                note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: AppColors.primary,
              ),
            ),
            IconButton(
              tooltip: l10n.noteDelete,
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) {
        return AlertDialog(
          title: Text(l10n.noteDelete),
          content: Text('${l10n.noteTitle}: ${note.title}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l10n.noteDelete),
            ),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      await context.read<NotesCubit>().deleteForUndo(note);
    }
  }
}
