import 'package:connectinno_notes/features/auth/auth_cubit.dart';
import 'package:connectinno_notes/features/auth/auth_state.dart';
import 'package:connectinno_notes/features/auth/login_page.dart';
import 'package:connectinno_notes/features/auth/signup_page.dart';
import 'package:connectinno_notes/features/notes/edit_note_page.dart';
import 'package:connectinno_notes/features/notes/notes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({required Listenable refreshListenable}) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final auth = context.read<AuthCubit>().state;
      final path = state.matchedLocation;
      if (auth is AuthSessionLoading) {
        return null;
      }
      if (auth is AuthAuthenticated) {
        if (path == '/login' || path == '/signup') {
          return '/notes';
        }
        return null;
      }
      if (path == '/login' || path == '/signup') {
        return null;
      }
      if (path.startsWith('/notes')) {
        return '/login';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage<void>(child: LoginPage()),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage<void>(child: SignupPage()),
      ),
      // More specific paths first
      GoRoute(
        path: '/notes/new',
        name: 'noteNew',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage<void>(child: EditNotePage()),
      ),
      GoRoute(
        path: '/notes/:noteId',
        name: 'noteEdit',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['noteId']!;
          return NoTransitionPage<void>(child: EditNotePage(existingNoteId: id));
        },
      ),
      GoRoute(
        path: '/notes',
        name: 'notes',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage<void>(child: NotesPage()),
      ),
    ],
  );
}
