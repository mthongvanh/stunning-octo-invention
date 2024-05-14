import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:r_tree/r_tree.dart';

import '../../domain/entities/oil_well.dart';

abstract class OilWellLocalDataSource {
  Future<List<OilWell>> loadWells();

  Future<List<OilWell>> closestWells(
    final Point center, {
    final Rect? visibleRect,
    final Set<OilWell> exclude,
    final int pageSize,
    final bool sort,
    final bool rTree,
  });
}

class OilWellLocalDataSourceImpl extends OilWellLocalDataSource {
  final List<OilWell> _cachedWells = [];
  final RTree<OilWell> _oilWellTree = RTree();

  int rTreeCount = 0;
  int rTreeTotal = 0;

  int naiveCount = 0;
  int naiveTotal = 0;

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
    Set<OilWell> exclude = const {},
    final int pageSize = 10,
    final bool sort = false,
    final bool rTree = false,
  }) async {
    exclude = {};
    if (rTree) {
      return closestWellsRTree_under100ms(
        center,
        exclude: exclude,
        pageSize: pageSize,
        latLongBoundingBox: visibleRect ??
            Rect.fromPoints(Offset(center.x.toDouble(), center.y.toDouble()),
                const Offset(0.0, 0.0)),
        sort: sort,
      );
    } else {
      return closestWells_5seconds(
        center,
        latLongBoundingBox: visibleRect ??
            Rect.fromPoints(Offset(center.x.toDouble(), center.y.toDouble()),
                const Offset(0.0, 0.0)),
        exclude: exclude,
        pageSize: pageSize,
        sort: sort,
      );
    }
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
  /// iPhone Xs
  /// sort discovered locations (items: 18690) from RTree.search -- 46 milliseconds
  /// search RTree -- 51 milliseconds
  /// sort discovered locations (items: 17535) from RTree.search -- 52 milliseconds
  /// search RTree -- 57 milliseconds
  /// sort discovered locations (items: 18342) from RTree.search -- 48 milliseconds
  /// search RTree -- 53 milliseconds
  /// sort discovered locations (items: 19224) from RTree.search -- 47 milliseconds
  /// search RTree -- 51 milliseconds
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
    final bool sort = true,
  }) async {
    List<OilWell> closestWells = [];
    List<OilWell> wells =
        _cachedWells.isNotEmpty ? _cachedWells.toList() : await loadWells();
    List<OilWell> discoveredItems = [];
    final rTreeTime = await Logger.duration(
      identifier: 'search RTree',
      operation: () async {
        final rectangle = Rectangle(
          latLongBoundingBox.left.toDouble(),
          latLongBoundingBox.top.toDouble(),
          latLongBoundingBox.width.toDouble(),
          latLongBoundingBox.height.toDouble(),
        );

        await Logger.duration(
            identifier: 'search tree and map items',
            operation: () {
              discoveredItems = _oilWellTree
                  .search(rectangle)
                  .take(60000)
                  .map((e) => e.value)
                  .toList();
            });

        await Logger.duration(
            identifier:
                'exclude items (${exclude.length}) from discovered (${discoveredItems.length})',
            operation: () {
              discoveredItems
                  .retainWhere((element) => !exclude.contains(element));
            });

        if (sort) {
          await Logger.duration(
              identifier: 'sort wells: count ${discoveredItems.length}',
              operation: () async {
                // classic distance-between-two-points
                // discoveredItems.sort((final a, final b) {
                //   final distanceA = Geolocator.distanceBetween(
                //       center.x.toDouble(),
                //       center.y.toDouble(),
                //       a.latitude.toDouble(),
                //       a.longitude.toDouble());
                //   final distanceB = Geolocator.distanceBetween(
                //       center.x.toDouble(),
                //       center.y.toDouble(),
                //       b.latitude.toDouble(),
                //       b.longitude.toDouble());
                //   return distanceA.compareTo(distanceB);
                // });

                // simplified
                discoveredItems.sort((final a, final b) {
                  final distanceALat =
                      (center.x.abs() - a.latitude.abs()).abs();
                  final distanceALng =
                      (center.y.abs() - a.longitude.abs()).abs();

                  final distanceBLat =
                      (center.x.abs() - b.latitude.abs()).abs();
                  final distanceBLng =
                      (center.y.abs() - b.longitude.abs()).abs();

                  return (distanceALat + distanceALng)
                      .compareTo(distanceBLat + distanceBLng);
                });
              });
        }

        closestWells = discoveredItems.take(pageSize).toList();
      },
    );

    rTreeTotal += rTreeTime;
    rTreeCount++;

    print('rTree,${discoveredItems.length},$rTreeTime');
    printStatus();
    return closestWells;
  }

  /// find wells in visible area -- 22 milliseconds
  /// sort wells: count 6135 -- 69 milliseconds
  /// load closest wells -- 93 milliseconds
  /// find wells in visible area -- 17 milliseconds
  /// sort wells: count 5908 -- 65 milliseconds
  /// load closest wells -- 83 milliseconds
  /// find wells in visible area -- 24 milliseconds
  /// sort wells: count 5882 -- 66 milliseconds
  /// load closest wells -- 90 milliseconds
  /// find wells in visible area -- 25 milliseconds
  /// sort wells: count 5882 -- 69 milliseconds
  /// load closest wells -- 94 milliseconds
  ///
  /// sort wells: count 42393 -- 585 milliseconds
  /// load closest wells -- 618 milliseconds
  /// find wells in visible area -- 29 milliseconds
  /// sort wells: count 28720 -- 390 milliseconds
  /// load closest wells -- 420 milliseconds
  /// find wells in visible area -- 27 milliseconds
  /// sort wells: count 21069 -- 288 milliseconds
  /// load closest wells -- 316 milliseconds
  /// find wells in visible area -- 27 milliseconds
  /// sort wells: count 16778 -- 212 milliseconds
  /// load closest wells -- 240 milliseconds
  Future<List<OilWell>> closestWells_5seconds(
    final Point center, {
    required final Rect latLongBoundingBox,
    final Set<OilWell> exclude = const {},
    final int pageSize = 10,
    final bool sort = true,
  }) async {
    List<OilWell> closestWells = [];
    List<OilWell> wells =
        _cachedWells.isNotEmpty ? _cachedWells.toList() : await loadWells();

    final withinBox = <OilWell>[];

    final naiveTime = await Logger.duration(
      identifier: 'load closest wells',
      operation: () async {
        await Logger.duration(
            identifier:
                'remove excluded items (${exclude.length}) from all wells (${wells.length})',
            operation: () {
              wells.retainWhere((element) => !exclude.contains(element));
            });

        await Logger.duration(
            identifier: 'find wells in visible area',
            operation: () {
              wells.retainWhere(
                (element) => latLongBoundingBox.contains(
                  Offset(
                    element.longitude,
                    element.latitude,
                  ),
                ),
              );
              withinBox.addAll(wells.take(60000));
              print('found ${withinBox.length} wells in visible area');
            });

        if (sort) {
          await Logger.duration(
              identifier: 'sort wells: count ${withinBox.length}',
              operation: () async {
                // classic distance-between-two-points
                // withinBox.sort((final a, final b) {
                //   final distanceA = Geolocator.distanceBetween(
                //       center.x.toDouble(),
                //       center.y.toDouble(),
                //       a.latitude.toDouble(),
                //       a.longitude.toDouble());
                //   final distanceB = Geolocator.distanceBetween(
                //       center.x.toDouble(),
                //       center.y.toDouble(),
                //       b.latitude.toDouble(),
                //       b.longitude.toDouble());
                //   return distanceA.compareTo(distanceB);
                // });

                // simplified
                withinBox.sort((final a, final b) {
                  final distanceALat =
                      (center.x.abs() - a.latitude.abs()).abs();
                  final distanceALng =
                      (center.y.abs() - a.longitude.abs()).abs();

                  final distanceBLat =
                      (center.x.abs() - b.latitude.abs()).abs();
                  final distanceBLng =
                      (center.y.abs() - b.longitude.abs()).abs();

                  return (distanceALat + distanceALng)
                      .compareTo(distanceBLat + distanceBLng);
                });
              });
        }

        closestWells = withinBox.take(pageSize).toList();
      },
    );
    naiveTotal += naiveTime;
    naiveCount++;
    print('nonR,${withinBox.length},$naiveTime');
    printStatus();
    return closestWells;
  }

  void printStatus() {
    print(
        'naive avg ${naiveTotal / naiveCount.toDouble()} ms ($naiveTotal total ms / $naiveCount times)');
    print(
        'r tree avg ${rTreeTotal / rTreeCount.toDouble()} ms ($rTreeTotal total ms / $rTreeCount times)');
  }
}

abstract class Logger {
  static Future<int> duration({
    required final String identifier,
    required FutureOr<void> Function() operation,
  }) async {
    final start = DateTime.now();
    await operation();
    final end = DateTime.now();
    print(
        'identifier: $identifier -- ${end.difference(start).inMilliseconds} milliseconds');
    return end.difference(start).inMilliseconds;
  }
}
