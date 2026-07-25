class ApiEndpoints {
  // استبدل هذا بعنوان IP جهازك إذا كنت تختبر على هاتف حقيقي أو المحاكي (10.0.2.2 لـ Android Emulator)
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static const String login = '$baseUrl/auth/login';
  static const String profile = '$baseUrl/auth/profile';
}