import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lyfer/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:lyfer/features/auth/presentation/providers/auth_provider.dart';
import 'package:lyfer/features/auth/presentation/screens/login_screen.dart';
import 'package:lyfer/features/auth/presentation/screens/signup_screen.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';
import 'package:lyfer/features/habits/presentation/screens/edit_habit_screen.dart';
import 'package:lyfer/features/habits/presentation/screens/habit_details.dart';
import 'package:lyfer/features/habits/presentation/screens/habits_screen.dart';
import 'package:lyfer/features/habits/presentation/screens/new_habit_screen.dart';
import 'package:lyfer/features/habits/data/repositories/habit_repository.dart';
import 'package:lyfer/features/home/presentation/screens/home_screen.dart';
import 'package:lyfer/features/notes/models/note_model.dart';
import 'package:lyfer/features/notes/presentation/screens/new_note_screen.dart';
import 'package:lyfer/features/notes/presentation/screens/note_screen.dart';
import 'package:lyfer/features/notes/services/note_service.dart';
import 'package:lyfer/features/settings/presentation/screens/settings_screen.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:lyfer/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:lyfer/features/tasks/presentation/screens/tasks_screen.dart';

class AppRouterConsts {
  static const String home = '/';
  static const String habits = '/habits';
  static const String newHabit = '/habits/new';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String habitDetails = '/habits/details';
  static const String note = '/habits/details/note';
  static const String habitEdit = '/habits/edit';
  static const String newNote = '/habits/new-note';
  static const String tasks = '/tasks';
  static const String newTask = '/tasks/new';
  static const String taskDetail = '/tasks/detail';
  static const String editTask = '/tasks/edit';
  static const String settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider).asData?.value;

  return GoRouter(
    initialLocation: AppRouterConsts.login,
    debugLogDiagnostics: true, // Add this for debugging
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoginRoute = state.matchedLocation == AppRouterConsts.login;
      final isSignupRoute = state.matchedLocation == AppRouterConsts.signup;
      final isVerifyRoute =
          state.matchedLocation == AppRouterConsts.verifyEmail;

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
          final habitService = ref.read(habitsRepositoryProvider.notifier);
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
          final habitService = ref.read(habitsRepositoryProvider.notifier);
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
      GoRoute(
        path: '${AppRouterConsts.note}/:habitId/:noteId',
        builder: (context, state) {
          final habitId = state.pathParameters['habitId']!;
          final noteId = state.pathParameters['noteId']!;

          // You'll need to fetch the note first
          final noteService = ref.read(noteServiceProvider);
          return FutureBuilder<NoteModel>(
            future: noteService.getNoteById(habitId, noteId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.hasError) {
                return const Scaffold(
                    body: Center(child: Text('Note not found')));
              }
              final note = snapshot.data!;
              return NoteScreen(
                habitId: habitId,
                note: note,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '${AppRouterConsts.newNote}/:habitId',
        builder: (context, state) {
          final habitId = state.pathParameters['habitId']!;
          return NewNoteScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: AppRouterConsts.newTask,
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '${AppRouterConsts.taskDetail}/:id',
        builder: (context, state) {
          final task = state.extra as Task;
          final id = state.pathParameters['id']!;
          return TaskDetailScreen(
            task: task,
          );
        },
      ),
      GoRoute(
        path: '${AppRouterConsts.editTask}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskFormScreen(taskId: id);
        },
      ),
      GoRoute(
        path: AppRouterConsts.settings,
        builder: (context, state) {
          return const SettingsScreen();
        },
      ),
    ],
  );
});
