import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _cooldownTimer;
  bool _isButtonDisabled = false;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Send verification email when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationEmail();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _isButtonDisabled = true;
      _cooldownSeconds = 60; // Changed to 30 seconds
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) {
          _isButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendVerificationEmail() async {
    await ref.read(authServiceProvider).sendEmailVerification();
    if (mounted) {
      final authState = ref.read(authStateChangesProvider).asData?.value;
      AppSnackbar.show(
        context: context,
        message: 'Verification email sent to ${authState?.email}',
      );
    }
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please verify your email to continue.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(authServiceProvider).signOut();
                context.go(AppRouterConsts.login); // Navigate to login
              },
              child: const Text('Login'), // Changed button text
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isButtonDisabled ? null : _sendVerificationEmail,
              child: Text(_isButtonDisabled
                  ? 'Resend in $_cooldownSeconds seconds'
                  : 'Resend Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}
