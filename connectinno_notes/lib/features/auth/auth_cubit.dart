import 'package:connectinno_notes/core/failures/app_failure.dart';
import 'package:connectinno_notes/features/auth/auth_repository.dart';
import 'package:connectinno_notes/features/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthSessionLoading()) {
    restoreSession();
  }

  final AuthRepository _repo;

  Future<void> restoreSession() async {
    final session = await _repo.readPersistedSession();
    if (session != null) {
      emit(session);
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthSubmitting());
    try {
      final next = await _repo.signIn(email: email, password: password);
      emit(next);
    } on AppFailure catch (e) {
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(const AuthSubmitting());
    try {
      final next = await _repo.signUp(email: email, password: password);
      emit(next);
    } on AppFailure catch (e) {
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthUnauthenticated());
  }
}
