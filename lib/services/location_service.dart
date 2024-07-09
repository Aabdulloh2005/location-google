import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  static final _location = Location();

  static bool _isServiceEnabled = false;
  static PermissionStatus _permissionStatus = PermissionStatus.denied;
  static LocationData? currentLocation;

  static Future<void> init() async {
    await _checkService();
    await _checkPermission();

    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      interval: 1000,
    );
  }

  static Future<void> _checkService() async {
    _isServiceEnabled = await _location.serviceEnabled();
    if (!_isServiceEnabled) {
      _isServiceEnabled = await _location.requestService();

      if (!_isServiceEnabled) {
        return;
      }
    }
  }

  static Future<void> _checkPermission() async {
    _permissionStatus = await _location.hasPermission();

    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return;
      }
    }
  }

  static Future<LocationData> getCurrentLocation() async {
    return currentLocation = await _location.getLocation();
  }

  static Stream<LocationData> getLiveLocation() async* {
    yield* _location.onLocationChanged;
  }

  static Future<List<LatLng>> fetchPolylinePoints(
    List<LatLng> points,
    TravelMode mode,
  ) async {
    final polylinePoints = PolylinePoints();
    List<LatLng> resultPoints = [];

    for (int i = 0; i < points.length - 1; i++) {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: "AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ",
        request: PolylineRequest(
          origin: PointLatLng(points[i].latitude, points[i].longitude),
          destination:
              PointLatLng(points[i + 1].latitude, points[i + 1].longitude),
          mode: mode,
        ),
      );
      print(result.distanceTexts);
      print(result.durationTexts);
      if (result.points.isNotEmpty) {
        resultPoints.addAll(result.points
            .map((point) => LatLng(point.latitude, point.longitude)));
      }
    }

    return resultPoints;
  }
}
