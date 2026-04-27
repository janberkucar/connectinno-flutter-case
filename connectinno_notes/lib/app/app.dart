import 'dart:async' show unawaited;

import 'package:connectinno_notes/app/router.dart';
import 'package:connectinno_notes/app/theme/app_theme.dart';
import 'package:connectinno_notes/bootstrap.dart';
import 'package:connectinno_notes/core/router/auth_router_refresh.dart';
import 'package:connectinno_notes/features/auth/auth_cubit.dart';
import 'package:connectinno_notes/features/auth/auth_repository.dart';
import 'package:connectinno_notes/features/notes/notes_cubit.dart';
import 'package:connectinno_notes/features/notes/notes_local_datasource.dart';
import 'package:connectinno_notes/features/notes/notes_remote_datasource.dart';
import 'package:connectinno_notes/features/notes/notes_repository.dart';
import 'package:connectinno_notes/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

class ConnectinnoApp extends StatefulWidget {
  const ConnectinnoApp({required this.bootstrap, super.key});

  final AppBootstrap bootstrap;

  @override
  State<ConnectinnoApp> createState() => _ConnectinnoAppState();
}

class _ConnectinnoAppState extends State<ConnectinnoApp> {
  late final AuthRepository _authRepository;
  late final NotesRepository _notesRepository;
  late final AuthCubit _authCubit;
  late final NotesCubit _notesCubit;
  late final AuthGoRouterRefresh _authRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      dio: widget.bootstrap.dioClient.dio,
      secureStorage: widget.bootstrap.secureStorage,
    );
    final local = NotesLocalDataSource(widget.bootstrap.notesBox);
    final remote = NotesRemoteDataSource(widget.bootstrap.dioClient.dio);
    _notesRepository = NotesRepository(
      local,
      remote,
      widget.bootstrap.connectivity,
    );
    _authCubit = AuthCubit(_authRepository);
    _notesCubit = NotesCubit(_notesRepository);
    _authRefresh = AuthGoRouterRefresh(_authCubit);
    _router = createAppRouter(
      refreshListenable: _authRefresh,
    );
  }

  @override
  void dispose() {
    _authRefresh.dispose();
    unawaited(_authCubit.close());
    unawaited(_notesCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<NotesRepository>.value(
      value: _notesRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _authCubit),
          BlocProvider<NotesCubit>.value(value: _notesCubit),
        ],
        child: MaterialApp.router(
          title: 'Connectinno Notes',
          theme: AppTheme.light(),
          routerConfig: _router,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[
            Locale('en'),
            Locale('tr'),
          ],
        ),
      ),
    );
  }
}
