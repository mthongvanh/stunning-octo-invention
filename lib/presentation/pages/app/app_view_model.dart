import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stunning_octo_invention/data/data_sources/oil_well_local_data_source.dart';
import 'package:stunning_octo_invention/domain/entities/oil_well.dart';

class AppViewModel {
  final OilWellLocalDataSource _oilWellLocalDataSource =
      OilWellLocalDataSourceImpl();

  GoogleMapController? _mapController;
  final markers = ValueNotifier(<Marker>{});
  final displayedOilWells = <OilWell>{};

  (double latitude, double longitude) get startLocation =>
      (_losAngeles.latitude, _losAngeles.longitude);

  final LatLng _losAngeles = const LatLng(34.052235, -118.243683);

  Future<List<OilWell>> loadWells() async {
    final wells = await _oilWellLocalDataSource.loadWells();

    return wells;
  }

  Future<void> init() async {}

  void onMapCreated(final GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers();
  }

  void onMapMoved() {
    _updateMarkers();
  }

  void _updateMarkers() {
    _mapController?.getVisibleRegion().then((value) async {
      final zoomLevel = await _mapController?.getZoomLevel();
      if ((zoomLevel ?? 0) < 7) {
        return;
      }
      // debugPrint('zoom level $zoomLevel');

      // debugPrint('visible region: $value');
      // debugPrint('visible center: ${value.center}');
      final closestWells = await _oilWellLocalDataSource.closestWells(
        Point(
          value.center.latitude,
          value.center.longitude,
        ),
        visibleRect: Rect.fromPoints(
          Offset(
            value.southwest.longitude.toDouble(),
            value.southwest.latitude.toDouble(),
          ),
          Offset(
            value.northeast.longitude.toDouble(),
            value.northeast.latitude.toDouble(),
          ),
        ),
        exclude: displayedOilWells,
      );

      displayedOilWells.addAll(closestWells);

      markers.value = displayedOilWells
          .map(
            (e) => Marker(
          markerId: MarkerId(e.identifier),
          position: LatLng(e.latitude, e.longitude),
        ),
      )
          .toSet();
    });
  }
}

extension CenterHelper on LatLngBounds {
  LatLng get center {
    final latCenter = northeast.latitude.toDouble() -
        (northeast.latitude.toDouble() - southwest.latitude.toDouble()) / 2.0;
    final longCenter = northeast.longitude.toDouble() -
        ((northeast.longitude.toDouble() - southwest.longitude.toDouble()) /
            2.0);
    return LatLng(latCenter, longCenter);
  }
}
