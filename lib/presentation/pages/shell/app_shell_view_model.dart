import 'package:flutter/material.dart';

import '../../../data/data_sources/discussion_local_data_source.dart';
import '../../../domain/entities/discussion.dart';

class AppShellViewModel {

  final discussions = ValueNotifier<List<Discussion>>([]);
  final currentDiscussion = ValueNotifier<Discussion?>(null);
  final rTreeEnabled = ValueNotifier(false);
  final applySort = ValueNotifier(false);
  final useDefaultAnimation = ValueNotifier(false);

  final DiscussionLocalDataSource _discussionLocalDataSource =
      MarkdownLocalDataSource();

  Future<void> init() async {
    loadDiscussions();
  }

  void loadDiscussions() {
    _discussionLocalDataSource.loadDiscussions().then((discussionData) {
      discussions.value = discussionData;
      currentDiscussion.value = discussionData.first;
    });
  }

  void updateCurrentDiscussion(final Discussion discussion) {
    currentDiscussion.value = discussion;
  }
}
