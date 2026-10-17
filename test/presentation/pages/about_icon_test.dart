import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/presentation/pages/system/about_page.dart';
import 'package:flutterbase/presentation/pages/system/licenses_page.dart';
import 'package:flutterbase/presentation/widgets/ui/widgets.dart';
import 'package:flutterbase/shared/theme/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/screenshot.dart';

/// `version: <name>+<build>` from pubspec.yaml, handed to PackageInfo as the
/// installed version (task #468).
final ({String name, String build}) _pubspecVersion = () {
  final line = File('pubspec.yaml')
      .readAsLinesSync()
      .firstWhere((l) => l.startsWith('version:'));
  final parts = line.substring('version:'.length).trim().split('+');
  return (name: parts[0], build: parts[1]);
}();

/// The About and Licenses pages show the app's own icon — the launcher's QR
/// code — not the template's generic placeholder (task #451).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'QRgen',
      packageName: 'com.nolumia.qrcorebasic',
      version: _pubspecVersion.name,
      buildNumber: _pubspecVersion.build,
      buildSignature: '',
    );
  });
  tearDown(sl.reset);

  Future<void> open(WidgetTester tester, Widget page) async {
    await preparePhoneScreen(tester);
    await tester.runAsync(setupServiceLocator);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: page));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('About shows the app icon', (tester) async {
    await open(tester, const AboutPage());

    expect(find.byType(AppIconMark), findsOneWidget);
    expect(find.byIcon(Icons.web_asset), findsNothing);
    await saveScreenshot(find.byType(AboutPage), 'about');
  });

  testWidgets('About shows the installed version and build number',
      (tester) async {
    // Not BuildInfo's placeholder ("26"), which only the release regenerates
    // (task #468).
    await open(tester, const AboutPage());

    expect(find.text(_pubspecVersion.name), findsOneWidget);
    expect(find.text(_pubspecVersion.build), findsOneWidget);
    await saveScreenshot(find.byType(AboutPage), 'about_version');
  });

  testWidgets('Licenses shows the app icon', (tester) async {
    await open(tester, const LicensesPage());

    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.byType(AppIconMark), findsOneWidget);
    await saveScreenshot(find.byType(LicensesPage), 'licenses');
  });
}
