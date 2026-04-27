import 'package:connectinno_notes/features/auth/models/app_user.dart';
import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Session not yet resolved (spinner on cold start while reading secure storage).
final class AuthSessionLoading extends AuthState {
  const AuthSessionLoading();
}

/// No valid session.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Sign-in or sign-up in progress.
final class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

/// Signed in; JWT and profile context are available for API + routing.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

/// Recoverable auth error (show message, keep form).
final class AuthFailureState extends AuthState {
  const AuthFailureState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
