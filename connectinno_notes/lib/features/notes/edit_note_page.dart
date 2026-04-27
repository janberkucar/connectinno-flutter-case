import 'dart:async' show unawaited;

import 'package:connectinno_notes/app/theme/app_spacing.dart';
import 'package:connectinno_notes/features/notes/notes_cubit.dart';
import 'package:connectinno_notes/features/notes/notes_repository.dart';
import 'package:connectinno_notes/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditNotePage extends StatefulWidget {
  const EditNotePage({this.existingNoteId, super.key});

  final String? existingNoteId;

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _noteId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _noteId = widget.existingNoteId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_hydrate());
      }
    });
  }

  Future<void> _hydrate() async {
    if (!mounted) {
      return;
    }
    final id = _noteId;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    final repo = context.read<NotesRepository>();
    final note = repo.getById(id);
    if (note == null) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note not found')),
        );
        context.pop();
      }
      return;
    }
    _title.text = note.title;
    _content.text = note.content;
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isNew = _noteId == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? l10n.newNote : l10n.editNote),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => _save(l10n),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextFormField(
              controller: _title,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.noteTitle),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _content,
              minLines: 6,
              maxLines: 12,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: l10n.noteContent,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!(_formKey.currentState?.validate() ?? true)) {
      return;
    }
    final cubit = context.read<NotesCubit>();
    if (_noteId == null) {
      await cubit.createNote(_title.text, _content.text);
    } else {
      final repo = context.read<NotesRepository>();
      final ex = repo.getById(_noteId!);
      if (ex == null) {
        if (context.mounted) {
          context.pop();
        }
        return;
      }
      await cubit.updateNote(
        ex.copyWith(
          title: _title.text,
          content: _content.text,
        ),
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noteSaved)),
      );
      context.pop();
    }
  }
}
