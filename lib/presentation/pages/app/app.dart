import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../widgets/search_header.dart';
import '../map/map_controller.dart';

class AppWidget extends StatefulWidget {
  final MapController _mapController;
  final FocusNode _searchFocus;

  const AppWidget(
    this._mapController,
    this._searchFocus, {
    super.key,
  });

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  TextEditingController controller = TextEditingController();

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
    return GoogleMap(
      onMapCreated: widget._mapController.onMapCreated,
      onCameraIdle: widget._mapController.onMapMoved,
      initialCameraPosition: const CameraPosition(
        target: LatLng(0, 0),
        zoom: 2,
      ),
      markers: const {},
    );
  }
}
