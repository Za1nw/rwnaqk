abstract final class AppRouteArgs {
  static const otpFlow = 'otp_flow';
  static const target = 'target';
  static const loginEmail = 'login_email';
  static const loginPassword = 'login_password';
  static const returnRoute = 'return_route';
  static const returnArgs = 'return_args';
}

enum OtpFlow { forgotPassword, twoFactorLogin }
