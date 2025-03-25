class AuthConstants {
  // Error codes
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String invalidEmail = 'invalid-email';
  static const String signInCanceled = 'sign_in_canceled';
  static const String googleSignInFailed = 'google_sign_in_failed';

  // Error messages
  static const String userNotFoundMessage = 'No user found for that email.';
  static const String wrongPasswordMessage =
      'Wrong password provided for that user.';
  static const String invalidEmailMessage = 'Invalid email provided.';
  static const String signInCanceledMessage = 'Sign in was canceled';
  static const String googleSignInFailedMessage =
      'Google Sign In failed. Please try again';
  static const String genericErrorMessage =
      'An error occurred. Please try again.';
  static const String emailVerificationSent = 'Verification email sent to ';

  // UI text
  static const String loginButtonText = 'Log In';
  static const String signUpButtonText = 'Sign Up';
  static const String googleSignInButtonText = 'Sign in with Google';
  static const String forgotPasswordText = 'Forgot Password?';
  static const String noAccountText = "Don't have an account?";
  static const String haveAccountText = 'Already have an account?';
  static const String welcomeBackText = 'Welcome Back!';
  static const String createAccountText = 'Create an Account';
  static const String verifyEmailTitle = 'Verify Email';
  static const String verifyEmailMessage =
      'Please verify your email to continue.';
  static const String resendVerificationEmail = 'Resend Verification Email';
  static const String resendInSecondsMessage = 'Resend in ';
  static const String secondsText = ' seconds';

  // Form validation
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';

  // Field labels
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';

  // Cooldown duration for email verification (in seconds)
  static const int verificationEmailCooldown = 60;
}
