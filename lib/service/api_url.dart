class ApiUrl {
  static const String baseUrl = 'https://onepipo.com/api/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/user/profile';
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String validateUsername = '/misc/validate/username';
  static const String validateReferralCode = '/misc/validate/refcode';
  static const String posts = '/posts';
}
