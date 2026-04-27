import 'dart:async' show StreamSubscription, unawaited;

import 'package:connectinno_notes/features/auth/auth_cubit.dart';
import 'package:connectinno_notes/features/auth/auth_state.dart';
import 'package:flutter/foundation.dart';

/// Feed [AuthCubit] into [GoRouter] via [ChangeNotifier] so [redirect] re-runs.
final class AuthGoRouterRefresh extends ChangeNotifier {
  AuthGoRouterRefresh(this._cubit) {
    _sub = _cubit.stream.listen((AuthState state) {
      if (kDebugMode) {
        // Auth transitions drive redirects; no debug spam.
      }
      notifyListeners();
    });
  }

  final AuthCubit _cubit;
  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
