import 'package:go_router/go_router.dart';
import 'package:lyfer/features/auth/view/screens/login_screen.dart';
import 'package:lyfer/features/auth/view/screens/signup_screen.dart';
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
}

final appRouter = GoRouter(
  initialLocation: AppRouterConsts.signup,
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
    )
  ],
);
