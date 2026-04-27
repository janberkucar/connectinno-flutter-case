import 'package:connectinno_notes/app/theme/app_colors.dart';
import 'package:connectinno_notes/app/theme/app_radius.dart';
import 'package:connectinno_notes/app/theme/app_spacing.dart';
import 'package:connectinno_notes/features/auth/auth_cubit.dart';
import 'package:connectinno_notes/features/auth/auth_state.dart';
import 'package:connectinno_notes/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: state is AuthSubmitting
                  ? null
                  : () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/login');
                      }
                    },
            ),
          ),
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
                            l10n.authCreateAccount,
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
                            autofillHints: const [AutofillHints.newPassword],
                            obscureText: true,
                            textInputAction: TextInputAction.next,
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
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _confirm,
                            obscureText: true,
                            onFieldSubmitted: (_) => _submit(context),
                            decoration: InputDecoration(
                              labelText: l10n.authConfirmPassword,
                            ),
                            validator: (v) {
                              if (v != _password.text) {
                                return l10n.errorGeneric;
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
                                : Text(l10n.authSignUp),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: state is AuthSubmitting
                                ? null
                                : () => context.go('/login'),
                            child: Text(l10n.authHasAccount),
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
    context.read<AuthCubit>().signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
  }
}
