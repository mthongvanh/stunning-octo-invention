import 'package:flutter/material.dart';

import '../../widgets/search_header.dart';

class SearchPage extends StatefulWidget {
  final String? initialText;
  const SearchPage({super.key, this.initialText,});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FocusNode focusNode = FocusNode();
  TextEditingController? controller;

  @override
  Widget build(BuildContext context) {

    controller ??= TextEditingController(text: widget.initialText);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(controller?.text);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: SearchHeader(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            showBackButton: true,
          ),
        ),
        body: const Center(
          child: Text(
            'Search for a location',
          ),
        ),
      ),
    );
  }
}
