import 'package:flutter/material.dart';

import '../../widgets/search_header.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: SearchHeader(
          focusNode: focusNode,
          autofocus: true,
        ),
      ),
      body: const Center(
        child: Text(
          'Search for a location',
        ),
      ),
    );
  }
}
