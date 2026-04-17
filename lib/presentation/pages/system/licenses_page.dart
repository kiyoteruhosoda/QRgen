import 'package:flutter/material.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/presentation/viewmodels/about_viewmodel.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';

/// Third-party package licenses page.
///
/// Backed by Flutter's [LicenseRegistry], which is automatically populated
/// with every dependency's LICENSE file at build time.
class LicensesPage extends StatefulWidget {
  const LicensesPage({super.key});

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  late final AboutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<AboutViewModel>();
    _viewModel.addListener(_onViewModelChange);
    if (_viewModel.appInfo == null) {
      _viewModel.loadAppInfo();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    super.dispose();
  }

  void _onViewModelChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final info = _viewModel.appInfo;
    return LicensePage(
      applicationName: AppStrings.appName,
      applicationVersion: info == null
          ? null
          : '${info.version} (${info.buildNumber})',
    );
  }
}
