import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stunning_octo_invention/presentation/pages/app/app_view_model.dart';

import '../map/map_controller.dart';

class AppWidget extends StatefulWidget {
  final MapController _mapController;
  final AppViewModel appViewModel;
  final FocusNode _searchFocus;

  const AppWidget(
    this._mapController,
    this._searchFocus, {
    required this.appViewModel,
    super.key,
  });

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  TextEditingController controller = TextEditingController();
  AppViewModel get viewModel => widget.appViewModel;

  @override
  void initState() {
    unawaited(widget.appViewModel.loadWells());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: const Border.fromBorderSide(
                    BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: TextButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).pushNamed(
                      'search',
                      arguments: controller.text,
                    );
                    controller.text = (result as String?) ?? '';
                  },
                  style: const ButtonStyle(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: controller,
                            builder: (context, value, _) {
                              return Text(
                                value.text ?? '',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            IconButton(
              onPressed: () {
                debugPrint('do something');
              },
              icon: const Icon(Icons.filter_list),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.white),
                  shape: MaterialStateProperty.resolveWith((states) =>
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(color: Colors.grey)))),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.lightGreen,
        child: _buildMap(),
      ),
    );
  }

  Widget _buildMap() {
    final start = viewModel.startLocation;
    return ValueListenableBuilder(
      valueListenable: viewModel.markers,
      builder: (final context, final markers, final _) {
        return GoogleMap(
          onMapCreated: viewModel.onMapCreated,
          onCameraIdle: viewModel.onMapMoved,
          initialCameraPosition: CameraPosition(
            target: LatLng(start.$1, start.$2),
            zoom: 9,
          ),
          markers: markers,
        );
      }
    );
  }
}
