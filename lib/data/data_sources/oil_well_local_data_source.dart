import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:r_tree/r_tree.dart';

import '../../domain/entities/oil_well.dart';

abstract class OilWellLocalDataSource {
  Future<List<OilWell>> loadWells();

  Future<List<OilWell>> closestWells(
    final Point center, {
    final Rect? visibleRect,
    final Set<OilWell> exclude,
    final int pageSize,
  });
}

class OilWellLocalDataSourceImpl extends OilWellLocalDataSource {
  final List<OilWell> _cachedWells = [];
  final RTree<OilWell> _oilWellTree = RTree();

  @override
  Future<List<OilWell>> loadWells() async {
    if (_cachedWells.isNotEmpty) {
      return _cachedWells.toList();
    }

    List<OilWell> wells = [];

    try {
      await Logger.duration(
        identifier: 'load wells from assets folder',
        operation: () async {
          String jsonString = '';
          await Logger.duration(
            identifier: 'load oil wells json inside logger',
            operation: () async {
              jsonString = await rootBundle.loadString(
                'assets/Oil_Wells.geojson',
                cache: false,
              );
            },
          );

          Map<String, dynamic> data = {};
          await Logger.duration(
            identifier: 'decode json string',
            operation: () => data = jsonDecode(jsonString),
          );

          List<dynamic> oilWellJson = data['features'];

          await Logger.duration(
            identifier: 'map json to oil well',
            operation: () async {
              for (final json in oilWellJson) {
                if (json
                    case {
                      'geometry': {
                        'coordinates': [
                          double longitude,
                          double latitude,
                        ]
                      },
                      'properties': {
                        'OBJECTID': int objectID,
                      }
                    }) {
                  final well = OilWell(
                    identifier: objectID.toString(),
                    latitude: latitude,
                    longitude: longitude,
                  );

                  wells.add(well);
                } else {
                  debugPrint('something happened');
                }
              }
            },
          );
        },
      );

      await Logger.duration(
          identifier: 'setup RTree',
          operation: () {
            _oilWellTree.add(wells
                .map((e) => RTreeDatum(
                    Rectangle(e.longitude, e.latitude, 0.0000001, 0.0000001),
                    e))
                .toList());
          });

      _cachedWells.clear();
      _cachedWells.addAll(wells);
    } catch (e) {
      debugPrint(e.toString());
    }

    return wells;
  }

  @override
  Future<List<OilWell>> closestWells(
    final Point center, {
    final Rect? visibleRect,
    final Set<OilWell> exclude = const {},
    final int pageSize = 10,
  }) async {
    // return closestWells_5seconds(center, exclude: exclude, pageSize: pageSize);
    return closestWellsRTree_under100ms(
      center,
      exclude: exclude,
      pageSize: pageSize,
      latLongBoundingBox: visibleRect ??
          Rect.fromPoints(Offset(center.x.toDouble(), center.y.toDouble()),
              const Offset(0.0, 0.0)),
    );
  }

  /// 500ms to load full json
  /// Oil_Wells.geojson:
  /// zoom level 8
  /// identifier: sort discovered locations (items: 28361) from RTree.search -- 394 milliseconds
  /// identifier: search RTree -- 426 milliseconds
  ///
  /// zoom level 9
  /// identifier: sort discovered locations (items: 6058) from RTree.search -- 73 milliseconds
  /// identifier: search RTree -- 81 milliseconds
  ///
  ///
  /// Oil_Wells_CA-only.geojson
  /// 127ms to create initial tree
  /// zoom level 8
  /// identifier: sort discovered locations (items: 28361) from RTree.search -- 368 milliseconds
  /// identifier: search RTree -- 386 milliseconds
  ///
  /// zoom level 9
  /// identifier: sort discovered locations (items: 5916) from RTree.search -- 67 milliseconds
  /// identifier: search RTree -- 72 milliseconds
  ///
  Future<List<OilWell>> closestWellsRTree_under100ms(
    final Point center, {
    required final Rect latLongBoundingBox,
    final Set<OilWell> exclude = const {},
    final int pageSize = 10,
  }) async {
    List<OilWell> closestWells = [];
    List<OilWell> wells =
        _cachedWells.isNotEmpty ? _cachedWells.toList() : await loadWells();
    await Logger.duration(
      identifier: 'search RTree',
      operation: () async {
        final rectangle = Rectangle(
          latLongBoundingBox.left.toDouble(),
          latLongBoundingBox.top.toDouble(),
          latLongBoundingBox.width.toDouble(),
          latLongBoundingBox.height.toDouble(),
        );

        final discoveredItems = _oilWellTree.search(rectangle);
        await Logger.duration(
            identifier:
                'sort discovered locations (items: ${discoveredItems.length}) from RTree.search',
            operation: () {
              discoveredItems.sort((final a, final b) {
                final distanceA = Geolocator.distanceBetween(
                    center.x.toDouble(),
                    center.y.toDouble(),
                    a.value.latitude.toDouble(),
                    a.value.longitude.toDouble());
                final distanceB = Geolocator.distanceBetween(
                    center.x.toDouble(),
                    center.y.toDouble(),
                    b.value.latitude.toDouble(),
                    b.value.longitude.toDouble());
                return distanceA.compareTo(distanceB);
              });
            });

        int index = 0;
        while (discoveredItems.isNotEmpty &&
            closestWells.length < pageSize &&
            index < (discoveredItems.length - 1)) {
          final oilWell = discoveredItems[index].value;
          if (!exclude.contains(oilWell)) {
            closestWells.add(oilWell);
          }
          index++;
        }
      },
    );
    return closestWells;
  }

  /// this implementation takes 5 seconds to loop through 330k oil wells
  Future<List<OilWell>> closestWells_5seconds(
    final Point center, {
    final Set<OilWell> exclude = const {},
    final int pageSize = 10,
  }) async {
    List<OilWell> closestWells = [];
    List<OilWell> wells =
        _cachedWells.isNotEmpty ? _cachedWells.toList() : await loadWells();
    await Logger.duration(
      identifier: 'load closest wells',
      operation: () async {
        wells.sort((final a, final b) {
          final distanceA = Geolocator.distanceBetween(
              center.x.toDouble(),
              center.y.toDouble(),
              a.latitude.toDouble(),
              a.longitude.toDouble());
          final distanceB = Geolocator.distanceBetween(
              center.x.toDouble(),
              center.y.toDouble(),
              b.latitude.toDouble(),
              b.longitude.toDouble());
          return distanceA.compareTo(distanceB);
        });

        int index = 0;
        while (closestWells.length < pageSize) {
          final oilWell = wells[index];
          if (!exclude.contains(oilWell)) {
            closestWells.add(oilWell);
          }
          index++;
        }
      },
    );
    return closestWells;
  }
}

abstract class Logger {
  static Future<void> duration({
    required final String identifier,
    required FutureOr<void> Function() operation,
  }) async {
    final start = DateTime.now();
    await operation();
    final end = DateTime.now();
    debugPrint(
        'identifier: $identifier -- ${end.difference(start).inMilliseconds} milliseconds');
  }
}
