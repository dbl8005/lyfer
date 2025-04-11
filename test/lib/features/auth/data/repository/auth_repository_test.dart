import 'package:flutter_test/flutter_test.dart';
import 'package:lyfer/features/auth/data/repository/auth_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:lyfer/features/auth/domain/models/user_model.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthRepository authRepository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();

    // Inject mocks via subclass or refactor your AuthRepository to accept them
    authRepository = AuthRepository.test(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('AuthRepository', () {
    // Test for sign in with email and password
    test('signInEmailPassword returns UserModel on success', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      // Stub fields accessed in UserModel.fromFirebaseUser()
      when(mockUser.uid).thenReturn('123');
      when(mockUser.email).thenReturn('test@email.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.emailVerified).thenReturn(true);
      when(mockUser.photoURL).thenReturn('http://example.com/photo.jpg');

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authRepository.signInEmailPassword(
          'test@gmail.com', 'password');

      expect(result, isA<UserModel>());
      expect(result?.uid, '123');
      expect(result?.email, 'test@email.com');
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'), password: anyNamed('password')))
          .called(1);
    });

    test('signInEmailPassword throws FirebaseAuthException on Firebase failure',
        () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(
          FirebaseAuthException(code: 'user-not-found', message: 'No user'));

      expect(
        () =>
            authRepository.signInEmailPassword('wrong@email.com', 'wrongpass'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInEmailPassword throws generic Exception on unknown error',
        () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Something unexpected'));

      expect(
        () => authRepository.signInEmailPassword('email', 'pass'),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('An error occurred during sign in'))),
      );
    });

    test(
      'signInEmailPassword returns null if UserCredential.user is null',
      () async {
        final mockUserCredential = MockUserCredential();
        when(mockUserCredential.user).thenReturn(null);
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer(
          (_) async => mockUserCredential,
        );
        final result =
            await authRepository.signInEmailPassword('email', 'password');
        expect(result, isNull);
      },
    );

    test(
      'If a user\' email is not verified it will return false',
      () async {
        final mockUser = MockUser();
        final mockUserCredential = MockUserCredential();
        when(mockUser.uid).thenReturn('123');
        when(mockUser.email).thenReturn('not@verified.com');
        when(mockUser.displayName).thenReturn('Unverified User');
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.photoURL).thenReturn(null);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer(
          (_) async => mockUserCredential,
        );
        final result = await authRepository.signInEmailPassword(
            'not@verified.com', 'password');
        expect(result, isA<UserModel>());
        expect(result?.isEmailVerified, isFalse);
      },
    );

    test('signOut calls FirebaseAuth.signOut and GoogleSignIn.signOut',
        () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async {});

      await authRepository.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });
  });
}
