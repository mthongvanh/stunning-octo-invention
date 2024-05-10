import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../presentation/pages/search/search_page.dart';

class AppRouter {
  static Route<dynamic> call(RouteSettings settings) {
    final name = settings.name;
    switch (name) {
      case 'search':
      case _:
        return PageRouteBuilder(
          pageBuilder: (context, animation,
              secondaryAnimation) =>
              SearchPage(initialText: settings.arguments as String?,),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
                begin: 0.0,
                end: 1.0
            ).chain(
              CurveTween(
                curve: Curves.easeOut,
              ),
            );
            return FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            );
          },
        );
    }
  }
}
