import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:stunning_octo_invention/navigation/app_router.dart';
import 'package:stunning_octo_invention/presentation/pages/app/app_view_model.dart';
import 'package:stunning_octo_invention/presentation/pages/shell/app_shell_view_model.dart';
import 'package:stunning_octo_invention/presentation/theme/app_theme.dart';

import '../app/app.dart';
import '../map/map_controller.dart';

/// [AppShellPage] will lock the height at 800px with an aspect ratio of 11.7/25.0
/// to simulate a phone in portrait mode
class AppShellPage extends StatefulWidget {
  final AppShellViewModel viewModel;

  const AppShellPage(
    this.viewModel, {
    super.key,
  });

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  AppShellViewModel get viewModel => widget.viewModel;

  final controller = MapController();
  final appViewModel = AppViewModel();
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
          child: ValueListenableBuilder(
            valueListenable: viewModel.currentDiscussion,
            builder: (context, discussion, child) {
              if (discussion == null) {
                return child ?? const SizedBox();
              }

              const pConfig = PConfig(
                textStyle: TextStyle(color: Colors.white),
              );

              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Wrap(
                        spacing: 8.0,
                        children: viewModel.discussions.value
                            .map(
                              (e) => ElevatedButton(
                                onPressed: () =>
                                    viewModel.updateCurrentDiscussion(e),
                                child: Text(
                                  e.identifier,
                                  // style: const TextStyle(
                                  //   color: Colors.white,
                                  // ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Scaffold(
                          backgroundColor: Colors.white24,
                          body: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: MarkdownWidget(
                              config: MarkdownConfig.darkConfig.copy(configs: [
                                pConfig,
                              ]),
                              data: discussion.markdown,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const CircularProgressIndicator(),
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  const SizedBox(
                    width: 250,
                    child: Text(
                      'Use Default Navigation Animation',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: viewModel.useDefaultAnimation,
                      builder: (context, enabled, _) {
                        return Switch(
                          value: enabled,
                          onChanged: (enabled) {
                            appViewModel.useDefaultAnimation.value = enabled;
                            viewModel.useDefaultAnimation.value = enabled;
                          },
                        );
                      })
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  const SizedBox(
                    width: 250,
                    child: Text(
                      'Use R Tree',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: viewModel.rTreeEnabled,
                      builder: (context, enabled, _) {
                        return Switch(
                          value: enabled,
                          onChanged: (enabled) {
                            appViewModel.applyRTree.value = enabled;
                            viewModel.rTreeEnabled.value = enabled;
                          },
                        );
                      })
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  const SizedBox(
                    width: 250,
                    child: Text(
                      'Apply Sort',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: viewModel.applySort,
                      builder: (context, enabled, _) {
                        return Switch(
                          value: enabled,
                          onChanged: (enabled) {
                            appViewModel.applySort.value = enabled;
                            viewModel.applySort.value = enabled;
                          },
                        );
                      })
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: SizedBox(
                height: _deviceHeight,
                child: AspectRatio(
                  aspectRatio: _aspectRatio,
                  child: _appWidget(),
                ),
              ),
            ),
          ],
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
        appViewModel: appViewModel,
      ),
    );
  }
}
