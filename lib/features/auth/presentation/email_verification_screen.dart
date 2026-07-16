import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_controller.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.isSignedIn) {
        context.go(AppRoutes.customerHome);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final verification = authState.emailVerification;

    if (verification == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AppButton(
                label: 'Create account',
                onPressed: () => context.go(AppRoutes.register),
              ),
            ),
          ),
        ),
      );
    }

    final expiresIn = verification.expiresAt.difference(DateTime.now());
    final resendIn = verification.resendAvailableAt.difference(DateTime.now());
    final isExpired = expiresIn.isNegative;
    final canResend = resendIn.isNegative || resendIn == Duration.zero;

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
                      'Check your email',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a verification code from noreply@frshnearby.com to ${verification.email}.',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExpired
                                ? 'Code expired'
                                : 'Code expires in ${_formatDuration(expiresIn)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          const Text('Check your inbox and spam folder.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Verification code',
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator:
                          (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'This field is required.'
                                  : null,
                    ),
                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        authState.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Verify email',
                      isLoading: authState.isLoading,
                      onPressed:
                          isExpired
                              ? null
                              : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .verifyEmailCode(_codeController.text);
                              },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed:
                          canResend && !authState.isLoading
                              ? () =>
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .resendEmailVerificationCode()
                              : null,
                      child: Text(
                        canResend
                            ? 'Resend code'
                            : 'Resend in ${_formatDuration(resendIn)}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Back to sign in'),
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

  String _formatDuration(Duration duration) {
    final safeDuration = duration.isNegative ? Duration.zero : duration;
    final minutes = safeDuration.inMinutes.remainder(60).toString();
    final seconds = safeDuration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
