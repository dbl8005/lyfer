import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/auth/presentation/widgets/auth_button.dart';
import 'package:lyfer/features/auth/presentation/widgets/email_form_field.dart';
import 'package:lyfer/features/auth/presentation/widgets/password_form_field.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authServiceProvider);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final bool _isLoading = false;
    Future<void> _login() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      try {
        await authProvider.signInEmailPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        context.go(AppRouterConsts.home);
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'user-not-found':
            AppSnackbar.show(
                context: context, message: 'No user found for that email.');
            break;
          case 'wrong-password':
            AppSnackbar.show(
                context: context,
                message: 'Wrong password provided for that user.');
            break;
          case 'invalid-email':
            AppSnackbar.show(
                context: context, message: 'Invalid email provided.');
            break;
          default:
            AppSnackbar.show(
                context: context, message: 'An error occurred: ${e.message}');
        }

        print(e);
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  EmailFormField(
                    controller: _emailController,
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PasswordFormField(
                    controller: _passwordController,
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 16),
            AuthButton(
                isLoading: _isLoading, onPressed: _login, text: 'Log In'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    context.go(AppRouterConsts.signup);
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
