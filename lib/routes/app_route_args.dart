abstract final class AppRouteArgs {
  static const otpFlow = 'otp_flow';
  static const target = 'target';
  static const loginEmail = 'login_email';
  static const loginPassword = 'login_password';
}

enum OtpFlow { forgotPassword, twoFactorLogin }
