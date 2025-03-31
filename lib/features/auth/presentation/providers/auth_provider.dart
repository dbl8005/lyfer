import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/auth/domain/models/user_model.dart';
import 'package:lyfer/features/auth/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider for the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider to stream authentication state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

// Provider to get current user model
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
    orElse: () => null,
  );
});

// Provider to check if email is verified
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user?.emailVerified ?? false,
    orElse: () => false,
  );
});
