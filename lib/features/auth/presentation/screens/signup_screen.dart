import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/error_dialog.dart';
import 'package:lyfer/core/utils/validators/email_validator.dart';
import 'package:lyfer/core/utils/validators/password_validator.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/auth/presentation/widgets/auth_button.dart';
import 'package:lyfer/features/auth/presentation/widgets/confirm_password_form_field.dart';
import 'package:lyfer/features/auth/presentation/widgets/email_form_field.dart';
import 'package:lyfer/features/auth/presentation/widgets/password_form_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await ref.read(authServiceProvider).signUpEmailPassword(
              _emailController.text.trim(),
              _passwordController.text,
            );

        if (user == null) {
          ErrorDialog.show(
            context,
            message: 'Failed to create account. Please try again.',
          );
        } else {
          context.go(AppRouterConsts.home);
        }
      } catch (e) {
        ErrorDialog.show(
          context,
          message: 'An error occurred: ${e.toString()}',
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    EmailFormField(
                      controller: _emailController,
                      validator: (p0) {
                        return EmailValidator.validate(p0);
                      },
                    ),
                    const SizedBox(height: 20),
                    PasswordFormField(
                      controller: _passwordController,
                      validator: (p0) {
                        return PasswordValidator.validate(p0);
                      },
                    ),
                    const SizedBox(height: 20),
                    ConfirmPasswordFormField(
                        controller: _confirmPasswordController,
                        passwordController: _passwordController),
                    const SizedBox(height: 30),
                    AuthButton(
                      isLoading: _isLoading,
                      onPressed: _signUp,
                      text: 'Sign Up',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            context.go(AppRouterConsts.login);
                          },
                          child: const Text('Log In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
