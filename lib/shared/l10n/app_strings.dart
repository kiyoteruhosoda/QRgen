/// Centralised English string resources.
/// All user-visible strings must come from this class — never hardcoded inline.
class AppStrings {
  AppStrings._();

  // ─── App ──────────────────────────────────────────────────────────────
  static const String appName = 'QRgen';
  static const String appDescription = 'QR code scanner and generator app';

  // ─── Navigation ───────────────────────────────────────────────────────
  static const String navHome = 'Scanner';
  static const String navSearch = 'Generator';
  static const String navSettings = 'Settings';

  // ─── Drawer ───────────────────────────────────────────────────────────
  static const String drawerSubtitle = 'QR Code App';
  static const String drawerClose = 'Close';
  static const String drawerAbout = 'About';
  static const String drawerLicenses = 'Licenses';
  static const String drawerDebug = 'Debug Info';
  static const String drawerLogs = 'Logs';

  // ─── QR Scanner tab ───────────────────────────────────────────────────
  static const String qrScannerTitle = 'QR Scanner';
  static const String qrScannerHint = 'Point the camera at a QR code';
  static const String qrScannerResult = 'Scan Result';
  static const String qrScannerNoResult = 'No QR code scanned yet';
  static const String qrScannerCopy = 'Copy';
  static const String qrScannerOpen = 'Open';
  static const String qrScannerCopied = 'Copied to clipboard';
  static const String qrScannerCannotOpen = 'Cannot open this content';
  static const String qrScannerPermissionDenied =
      'Camera permission is required to scan QR codes';
  static const String qrScannerPermissionRequest = 'Grant Permission';
  static const String qrScannerTorchOn = 'Flash On';
  static const String qrScannerTorchOff = 'Flash Off';
  static const String qrScannerSwitchCamera = 'Switch Camera';

  // ─── QR Generator tab ─────────────────────────────────────────────────
  static const String qrGeneratorTitle = 'QR Generator';
  static const String qrGeneratorInputLabel = 'Text or URL';
  static const String qrGeneratorInputHint = 'Enter text or URL to generate QR code';
  static const String qrGeneratorButton = 'Generate';
  static const String qrGeneratorNoCode = 'Enter text above and tap Generate';
  static const String qrGeneratorCopy = 'Copy Text';
  static const String qrGeneratorDownload = 'Save Image';
  static const String qrGeneratorCopied = 'Text copied to clipboard';
  static const String qrGeneratorSaved = 'QR code saved to Downloads';
  static const String qrGeneratorSaveError = 'Failed to save QR code';

  // ─── Settings tab ─────────────────────────────────────────────────────
  static const String settingsTitle = 'Settings';
  static const String settingsTheme = 'Theme';
  static const String settingsThemeSystem = 'System default';
  static const String settingsThemeLight = 'Light';
  static const String settingsThemeDark = 'Dark';
  static const String settingsAbout = 'About';
  static const String settingsLicenses = 'Licenses';
  static const String settingsDebug = 'Debug Info';
  static const String settingsLogs = 'Logs';

  // ─── Footer ───────────────────────────────────────────────────────────
  static const String footerAbout = 'About';
  static const String footerLicenses = 'Licenses';

  // ─── About page ───────────────────────────────────────────────────────
  static const String aboutTitle = 'About';
  static const String aboutVersion = 'Version';
  static const String aboutBuildNumber = 'Build Number';
  static const String aboutGitCommit = 'Git Commit';
  static const String aboutFlutterVersion = 'Flutter Version';
  static const String aboutDartVersion = 'Dart Version';
  static const String aboutDesignSystem = 'Design System';
  static const String aboutDesignSystemValue = 'DADS v2.10.3';
  static const String aboutPlatform = 'Platform';
  static const String aboutPlatformValue = 'Android / iOS';
  static const String aboutDesignSystemSectionTitle = 'Design System';
  static const String aboutDesignSystemBody =
      'This app is built following the Design System\nprovided by the Digital Agency of Japan (DADS).';
  static const String aboutDesignSystemLink = 'Official Design System Website';

  // ─── Debug page ───────────────────────────────────────────────────────
  static const String debugTitle = 'Debug Info';
  static const String debugWarning =
      'This page is for debug purposes only. Do not display in release builds.';
  static const String debugAppInfoSection = 'App Info';
  static const String debugThemeSection = 'Theme Info';
  static const String debugThemeMode = 'Theme Mode';
  static const String debugThemeModeDark = 'Dark Mode';
  static const String debugThemeModeLight = 'Light Mode';
  static const String debugPrimaryColor = 'Primary Color';
  static const String debugSurfaceColor = 'Surface Color';
  static const String debugActionsSection = 'Debug Actions';
  static const String debugClearLogs = 'Clear Logs';
  static const String debugClearLogsSuccess = 'Logs cleared';
  static const String debugClearCache = 'Clear Cache';
  static const String debugClearCacheSuccess = 'Cache cleared';
  static const String debugTestCrash = 'Test Crash';
  static const String debugTestCrashTitle = 'Test Crash';
  static const String debugTestCrashBody =
      'Crash the app for testing purposes?';
  static const String debugCopyAll = 'Copy All';
  static const String debugCopiedToClipboard = 'Copied to clipboard';
  static const String debugCancel = 'Cancel';
  static const String debugCrash = 'Crash';
  static const String debugAppName = 'App Name';
  static const String debugVersion = 'Version';
  static const String debugBuildNumber = 'Build Number';
  static const String debugGitCommit = 'Git Commit';
  static const String debugFlutterVersion = 'Flutter Version';
  static const String debugDartVersion = 'Dart Version';
  static const String debugPlatform = 'Platform';
  static const String debugDesignSystem = 'Design System';
  static const String debugBuildDate = 'Build Date';
  static const String debugIsDebugBuild = 'Debug Build';

  // ─── Logs page ────────────────────────────────────────────────────────
  static const String logsTitle = 'Logs';
  static const String logsAll = 'All';
  static const String logsVerbose = 'Verbose';
  static const String logsDebug = 'Debug';
  static const String logsInfo = 'Info';
  static const String logsWarning = 'Warning';
  static const String logsError = 'Error';
  static const String logsClear = 'Clear';
  static const String logsClearConfirmTitle = 'Clear Logs';
  static const String logsClearConfirmBody =
      'Delete all log entries from memory?';
  static const String logsClearSuccess = 'Logs cleared';
  static const String logsDownload = 'Export';
  static const String logsDownloadSuccess = 'Logs saved to file';
  static const String logsDownloadError = 'Failed to save logs';
  static const String logsEmpty = 'No log entries';
  static const String logsCancel = 'Cancel';
  static const String logsConfirm = 'Clear';
  static const String logsCopied = 'Log entry copied';

  // ─── Developer settings ───────────────────────────────────────────────
  static const String settingsDeveloper = 'Developer';
  static const String settingsDebugMode = 'Debug Mode';
  static const String settingsDebugModeSubtitle =
      'Show Logs and Debug Info menu items';
  static const String settingsLogLevel = 'Log Level';
  static const String logLevelVerbose = 'Verbose';
  static const String logLevelDebug = 'Debug';
  static const String logLevelInfo = 'Info';
  static const String logLevelWarning = 'Warning';
  static const String logLevelError = 'Error';

  // ─── Licenses page ───────────────────────────────────────────────────
  static const String licensesTitle = 'Licenses';
  static const String licensesDetails =
      'Please refer to the package license file for details.';

  // ─── Splash screen ───────────────────────────────────────────────────
  static const String splashSubtitle = 'QR Code Scanner & Generator';

  // ─── Common ──────────────────────────────────────────────────────────
  static const String commonRetry = 'Retry';
  static const String commonMenu = 'Menu';
  static const String commonNotifications = 'Notifications';
  static const String commonNotFound = '404 - Page not found';
  static const String commonPageNotFound = 'Page Not Found';
  static const String commonLoading = 'Loading...';
  static const String commonError = 'An error occurred';
  static const String commonEmpty = 'No data';
}
