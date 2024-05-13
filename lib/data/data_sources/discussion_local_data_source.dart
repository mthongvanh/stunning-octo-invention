import 'dart:async';

import 'package:flutter/services.dart';
import 'package:stunning_octo_invention/domain/entities/discussion.dart';

abstract class DiscussionLocalDataSource {
  Future<List<Discussion>> loadDiscussions();
}

class MarkdownLocalDataSource extends DiscussionLocalDataSource {
  final _cached = <Discussion>[];

  @override
  Future<List<Discussion>> loadDiscussions() async {
    if (_cached.isNotEmpty) {
      return _cached;
    }

    final markdownStrings = <Discussion>[];
    for (final rawData in _mdFilenames()) {
      final mdString = await rootBundle.loadString(rawData.filename);
      final discussion =
          Discussion(identifier: rawData.topic, markdown: mdString);
      markdownStrings.add(discussion);
    }

    _cached.clear();
    _cached.addAll(markdownStrings);

    return markdownStrings;
  }

  List<({String topic, String filename})> _mdFilenames() {
    return [
      (
        topic: 'Search Animation',
        filename: 'assets/animation_search.md',
      ),
      (
        topic: 'Cached Locations',
        filename: 'assets/cached_location_loading.md'
      ),
    ];
  }
}
