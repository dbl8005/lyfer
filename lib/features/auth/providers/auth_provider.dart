import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/auth/services/auth_service.dart';
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
