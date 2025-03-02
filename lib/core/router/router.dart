import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lyfer/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/auth/presentation/screens/login_screen.dart';
import 'package:lyfer/features/auth/presentation/screens/signup_screen.dart';
import 'package:lyfer/features/home/home_screen.dart';

class AppRouterConsts {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String notFound = '/not-found';
  static const String verifyEmail = '/verify-email';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider).asData?.value;

  return GoRouter(
    initialLocation: AppRouterConsts.login,
    redirect: (context, state) {
      final isLoggedIn = authState != null;

      if (isLoggedIn) {
        final User? user = authState;
        print(user);
        if (user?.emailVerified == false) {
          return AppRouterConsts.verifyEmail;
        }
        return AppRouterConsts.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRouterConsts.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRouterConsts.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouterConsts.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRouterConsts.verifyEmail,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
    ],
  );
});
