import 'package:connectinno_notes/app/theme/app_colors.dart';
import 'package:connectinno_notes/app/theme/app_radius.dart';
import 'package:connectinno_notes/app/theme/app_spacing.dart';
import 'package:connectinno_notes/features/auth/auth_cubit.dart';
import 'package:connectinno_notes/features/auth/auth_state.dart';
import 'package:connectinno_notes/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthSessionLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.authLogin,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (state is AuthFailureState)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Material(
                                color: AppColors.pinned,
                                borderRadius: AppRadius.borderSm,
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Text(
                                    state.message,
                                    style: const TextStyle(color: AppColors.textPrimary),
                                  ),
                                ),
                              ),
                            ),
                          TextFormField(
                            controller: _email,
                            autofillHints: const [AutofillHints.email],
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.authEmail,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return l10n.errorGeneric;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _password,
                            autofillHints: const [AutofillHints.password],
                            obscureText: true,
                            onFieldSubmitted: (_) => _submit(context),
                            decoration: InputDecoration(
                              labelText: l10n.authPassword,
                            ),
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return l10n.errorAuth;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: state is AuthSubmitting ? null : () => _submit(context),
                            child: state is AuthSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(l10n.authLogin),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: state is AuthSubmitting
                                ? null
                                : () => context.push('/signup'),
                            child: Text(l10n.authNoAccount),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthCubit>().signIn(
          email: _email.text.trim(),
          password: _password.text,
        );
  }
}
