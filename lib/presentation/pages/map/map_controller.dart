
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController {
  GoogleMapController? _mapController;

  Future<void> init() async {

  }

  void onMapCreated(final GoogleMapController controller) {
    _mapController ??= controller;

    debugPrint(controller.toString());
  }

  void onMapMoved() {
    _mapController?.getVisibleRegion().then((value) {});
  }

  Set<Marker> get _markers => {
    Marker(markerId: MarkerId(DateTime.now().toString())),
  };
}