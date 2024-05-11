import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../presentation/pages/search/search_page.dart';

class AppRouter {
  static Route<dynamic> call(RouteSettings settings) {
    final name = settings.name;
    switch (name) {
      case 'search':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => SearchPage(
            initialText: settings.arguments as String?,
          ),
          transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      case _:
        return PageRouteBuilder(
            pageBuilder: (ctx, animation, secondaryAnimation) =>
                const SearchPage());
    }
  }
}
