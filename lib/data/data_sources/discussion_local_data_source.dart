import 'dart:async';

import 'package:flutter/services.dart';

abstract class DiscussionLocalDataSource {
  Future<List<String>> loadDiscussions();
}

class MarkdownLocalDataSource extends DiscussionLocalDataSource {

  final _cached = <String>[];

  @override
  Future<List<String>> loadDiscussions() async {
    if (_cached.isNotEmpty) {
      return _cached;
    }

    final markdownStrings = <String>[];
    for (final assetName in _mdFilenames()) {
      final mdString = await rootBundle.loadString(assetName);
      markdownStrings.add(mdString);
    }

    _cached.clear();
    _cached.addAll(markdownStrings);

    return markdownStrings;
  }

  List<String> _mdFilenames() {
    return [
      'assets/animation_search.md',
    ];
  }
}