import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final FocusNode focusNode;
  final bool searchEnabled;
  final bool autofocus;
  final bool showBackButton;
  final TextEditingController? controller;

  const SearchHeader({
    super.key,
    required this.focusNode,
    this.autofocus = false,
    this.controller,
    this.showBackButton = false,
    this.searchEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Hero(
            tag: 'locationSearchField',
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Colors.grey,
                  )),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.background,
                    prefixIcon: showBackButton
                        ? _buildBackButton(context)
                        : _buildSearchIcon(context),
                ),
                autofocus: autofocus,
                enabled: searchEnabled,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12.0,
        ),
        IconButton(
          onPressed: () {
            debugPrint('do something');
          },
          icon: const Icon(Icons.filter_list),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.resolveWith((states) => Colors.white),
              shape: MaterialStateProperty.resolveWith((states) =>
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.grey)))),
        )
      ],
    );
  }

  IconButton _buildBackButton(final BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop(controller?.text);
      },
      icon: const Icon(
        Icons.arrow_back_ios_new,
      ),
    );
  }

  Icon _buildSearchIcon(final BuildContext context) {
    return const Icon(
      Icons.search,
    );
  }
}
