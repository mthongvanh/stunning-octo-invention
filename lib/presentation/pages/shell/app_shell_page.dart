import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:stunning_octo_invention/navigation/app_router.dart';
import 'package:stunning_octo_invention/presentation/pages/shell/app_shell_view_model.dart';
import 'package:stunning_octo_invention/presentation/theme/app_theme.dart';

import '../app/app.dart';
import '../map/map_controller.dart';

/// [AppShellPage] will lock the height at 800px with an aspect ratio of 11.7/25.0
/// to simulate a phone in portrait mode
class AppShellPage extends StatefulWidget {

  final AppShellViewModel viewModel;

  const AppShellPage(this.viewModel, {
    super.key,
  });

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  AppShellViewModel get viewModel => widget.viewModel;

  final controller = MapController();
  final focusNode = FocusNode();

  final _aspectRatio = 11.7 / 25.0;
  final _deviceHeight = 700.0;

  @override
  void initState() {
    viewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (kIsWeb) {
      content = _buildWebLayout();
    } else {
      content = _appWidget();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(builder: (context, constraints) {
        return ColoredBox(
          color: AppTheme().purple,
          child: SizedBox(
            height: max(640, constraints.maxHeight),
            width: max(800, constraints.maxWidth),
            child: content,
          ),
        );
      }),
    );
  }

  /// builds the wide-screen two column layout with discussion on the left
  /// and device frame with app content on the right
  Widget _buildWebLayout() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Scaffold(
                backgroundColor: Colors.white24,
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ValueListenableBuilder(
                      valueListenable: viewModel.currentDiscussion,
                      builder: (context, discussion, _) {
                        return MarkdownWidget(
                          config: MarkdownConfig.darkConfig,
                          data: discussion,
                        );
                      }
                  ),
                ),
              ),
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildMobileContent(),
          ],
        ),
      ],
    );
  }

  /// widget simulates the mobile device
  Widget _buildMobileContent() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: SizedBox(
          height: _deviceHeight,
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: _appWidget(),
          ),
        ),
      ),
    );
  }

  /// application content
  MaterialApp _appWidget() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.call,
      home: AppWidget(
        controller,
        focusNode,
      ),
    );
  }
}
