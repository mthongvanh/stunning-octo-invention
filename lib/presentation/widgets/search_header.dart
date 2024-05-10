import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final FocusNode focusNode;
  final bool autofocus;

  const SearchHeader({
    super.key,
    required this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Hero(
            tag: 'locationSearchField',
            child: Material(
              child: TextField(
                focusNode: focusNode,
                decoration: const InputDecoration(),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12.0,
        ),
        OutlinedButton(
          onPressed: () {
            debugPrint('do something');
          },
          child: const Icon(Icons.filter_list),
        )
      ],
    );
  }
}
