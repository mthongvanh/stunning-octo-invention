import 'package:flutter/material.dart';

import '../../../data/data_sources/discussion_local_data_source.dart';

class AppShellViewModel {

  final discussions = ValueNotifier<List<String>>([]);
  final currentDiscussion = ValueNotifier<String>('');

  final DiscussionLocalDataSource _discussionLocalDataSource =
      MarkdownLocalDataSource();

  Future<void> init() async {
    loadDiscussions();
  }

  void loadDiscussions() {
    _discussionLocalDataSource.loadDiscussions().then((mdStrings) {
      discussions.value = mdStrings;
      currentDiscussion.value = mdStrings.first;
    });
  }
}
