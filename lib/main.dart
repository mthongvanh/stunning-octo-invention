

import 'package:flutter/material.dart';
import 'package:stunning_octo_invention/presentation/pages/shell/app_shell_view_model.dart';

import 'presentation/pages/shell/app_shell_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppShellViewModel vm = AppShellViewModel();
  runApp(AppShellPage(vm));
}