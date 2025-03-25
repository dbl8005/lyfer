import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/constants/app_constants.dart';
import 'package:lyfer/core/constants/ui_constants.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/auth/constants/auth_constants.dart';
import 'package:lyfer/features/auth/presentation/providers/auth_provider.dart';
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
  void initState() {
    super.initState();
    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = ref.read(authServiceProvider);
      if (authService.isAuthenticated) {
        context.go(AppRouterConsts.home);
      }
    });
  }

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
        final user = authProvider.currentUser;
        if (user != null && !user.emailVerified) {
          context.go(AppRouterConsts.verifyEmail);
        } else {
          context.go(AppRouterConsts.home);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case AuthConstants.userNotFound:
          message = AuthConstants.userNotFoundMessage;
          break;
        case AuthConstants.wrongPassword:
          message = AuthConstants.wrongPasswordMessage;
          break;
        case AuthConstants.invalidEmail:
          message = AuthConstants.invalidEmailMessage;
          break;
        default:
          message = e.message ?? AuthConstants.genericErrorMessage;
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
        case AuthConstants.signInCanceled:
          message = AuthConstants.signInCanceledMessage;
          break;
        case AuthConstants.googleSignInFailed:
          message = AuthConstants.googleSignInFailedMessage;
          break;
        default:
          message = e.message ?? AuthConstants.genericErrorMessage;
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
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              AuthConstants.welcomeBackText,
              style: UIConstants.subheadingStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.extraLargeSpacing),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  EmailFormField(
                    controller: _emailController,
                    validator: (value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.s),
                  PasswordFormField(
                    controller: _passwordController,
                    validator: (value) {
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
                    // Use GoRouter instead of Navigator for consistent navigation
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
