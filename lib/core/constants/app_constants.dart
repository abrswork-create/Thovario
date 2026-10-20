/// Global application constants for Thovario.
class AppConstants {
  AppConstants._();

  static const String appName = 'Thovario';
  static const String appTagline = 'Your words can stay here.';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // URLs (Prepared real policy URL placeholder for production metadata)
  static const String privacyPolicyUrl =
      'https://abrswork.com/thovario/privacy';
  static const String supportUrl = 'https://abrswork.com/thovario/support';

  // Editor limits
  static const int maxTitleLength = 100;
  static const int previewContentLength = 120;
}
