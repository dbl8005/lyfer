import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lyfer/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/auth/presentation/screens/login_screen.dart';
import 'package:lyfer/features/auth/presentation/screens/signup_screen.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/screens/edit_habit_screen.dart';
import 'package:lyfer/features/habits/presentation/screens/habit_details.dart';
import 'package:lyfer/features/habits/presentation/screens/habits_screen.dart';
import 'package:lyfer/features/habits/presentation/screens/new_habit_screen.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';
import 'package:lyfer/features/home/presentation/screens/home_screen.dart';

class AppRouterConsts {
  static const String home = '/';
  static const String habits = '/habits';
  static const String newHabit = '/habits/new';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String habitDetails = '/habits/details';
  static const String habitEdit = '/habits/edit';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider).asData?.value;

  return GoRouter(
    initialLocation: AppRouterConsts.login,
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoginRoute = state.path == AppRouterConsts.login;
      final isSignupRoute = state.path == AppRouterConsts.signup;
      final isVerifyRoute = state.path == AppRouterConsts.verifyEmail;

      // If not logged in, only allow access to login and signup
      if (!isLoggedIn && !isLoginRoute && !isSignupRoute) {
        return AppRouterConsts.login;
      }

      // If logged in but email not verified, only allow access to verify email page
      if (isLoggedIn && authState.emailVerified == false && !isVerifyRoute) {
        return AppRouterConsts.verifyEmail;
      }

      // If logged in and trying to access login/signup pages, redirect to home
      if (isLoggedIn &&
          authState.emailVerified &&
          (isLoginRoute || isSignupRoute)) {
        return AppRouterConsts.home;
      }

      // Allow navigation to the requested page
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
      GoRoute(
        path: AppRouterConsts.habits,
        builder: (context, state) => const HabitsScreen(),
      ),
      GoRoute(
        path: AppRouterConsts.newHabit,
        builder: (context, state) => const NewHabitScreen(),
      ),
      GoRoute(
        path: '${AppRouterConsts.habitEdit}/:id',
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          // You'll need to fetch the habit first
          final habitService = ref.read(habitServiceProvider);
          return FutureBuilder<HabitModel>(
            future: habitService.getHabitById(habitId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.hasError) {
                return const Scaffold(
                    body: Center(child: Text('Habit not found')));
              }
              return EditHabitScreen(habit: snapshot.data!);
            },
          );
        },
      ),
      GoRoute(
        path: '${AppRouterConsts.habitDetails}/:id',
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          // You'll need to fetch the habit first
          final habitService = ref.read(habitServiceProvider);
          return FutureBuilder<HabitModel>(
            future: habitService.getHabitById(habitId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.hasError) {
                return const Scaffold(
                    body: Center(child: Text('Habit not found')));
              }
              return HabitDetails(habit: snapshot.data!);
            },
          );
        },
      ),
    ],
  );
});
