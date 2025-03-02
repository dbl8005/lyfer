import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/auth/presentation/widgets/auth_button.dart';
import 'package:lyfer/features/auth/presentation/widgets/email_form_field.dart';
import 'package:lyfer/features/auth/presentation/widgets/password_form_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = ref.read(authServiceProvider);
      await authProvider.signInEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        context.go(AppRouterConsts.home);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = ref.read(authServiceProvider);
      await authProvider.signInWithGoogle();

      if (mounted) {
        context.go(AppRouterConsts.home);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'sign_in_canceled':
          message = 'Sign in was canceled';
          break;
        case 'google_sign_in_failed':
          message = 'Google Sign In failed. Please try again';
          break;
        default:
          message = e.message ?? 'An error occurred during sign in';
      }

      AppSnackbar.show(context: context, message: message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // TODO: Handle forgot password
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 16),
            AuthButton(
              isLoading: _isLoading,
              onPressed: _login,
              text: 'Log In',
            ),
            const SizedBox(height: 16),
            AuthButton(
              isLoading: _isLoading,
              onPressed: _googleSignIn,
              text: 'Sign in with Google',
              buttonColor: Colors.red,
              leadingIcon: Icon(
                LineIcons.googlePlusG,
                color: Colors.white,
                size: 30,
              ),
            ),
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
