import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/forms/app_validators.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.loginTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.loginSubtitle),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: l10n.emailLabel,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) => AppValidators.email(l10n, value),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: l10n.passwordLabel,
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) => AppValidators.required(l10n, value),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: l10n.loginButton,
                      isLoading: authState.isLoading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        await ref
                            .read(authControllerProvider.notifier)
                            .login(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                        if (!context.mounted) {
                          return;
                        }
                        if (ref
                            .read(authControllerProvider)
                            .hasPendingEmailVerification) {
                          context.go(AppRoutes.verifyEmail);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: Text(
                        '${l10n.createAccountPrompt} ${l10n.registerButton}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
