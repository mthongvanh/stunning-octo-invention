import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();

    widget._searchFocus.addListener(() async {
      if (widget._searchFocus.hasFocus) {
        widget._searchFocus.unfocus();
        var result = await Navigator.of(context).pushNamed(
          'search',
          arguments: controller.text,
        );
        controller.text = result as String? ?? '';
      }
    });
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
        title: SearchHeader(
          controller: controller,
          focusNode: widget._searchFocus,
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
