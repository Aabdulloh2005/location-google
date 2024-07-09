import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:lesson72/services/location_service.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;
  final LatLng najotTalim = const LatLng(41.2856806, 69.2034646);
  LatLng myCurrentPosition = LatLng(41.2856806, 69.2034646);
  Set<Marker> myMarkers = {};
  Set<Polyline> polylines = {};
  List<LatLng> myPositions = [];
  TravelMode travelMode = TravelMode.driving;
  MapType mapType = MapType.normal;
  final TextEditingController _textEditingController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await LocationService.getCurrentLocation();
      setState(() {});
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      myCurrentPosition = position.target;
    });
  }

  void watchMyLocation() {
    LocationService.getLiveLocation().listen((location) {
      print("Live location: $location");
    });
  }

  void addLocationMarker() {
    setState(() {
      myMarkers.add(
        Marker(
          markerId: MarkerId(myMarkers.length.toString()),
          position: myCurrentPosition,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );

      myPositions.add(myCurrentPosition);

      if (myPositions.length > 1) {
        LocationService.fetchPolylinePoints(myPositions, travelMode)
            .then((List<LatLng> positions) {
          setState(() {
            polylines.add(
              Polyline(
                polylineId: PolylineId(UniqueKey().toString()),
                color: Colors.teal,
                width: 5,
                points: positions,
              ),
            );
          });
        });
      }
    });
  }

  void _goToCurrentLocation() {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: najotTalim,
          zoom: 16.0,
        ),
      ),
    );
  }

  void _changeTravelMode(TravelMode mode) {
    setState(() {
      travelMode = mode;
    });
  }

  void _changeMapType(MapType type) {
    mapType = type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onLongPress: (argument) {
              addLocationMarker();
              setState(() {});
            },
            onTap: (argument) {
              myMarkers.clear();
              myPositions.clear();
              polylines.clear();
              setState(() {});
            },
            buildingsEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: najotTalim,
              zoom: 16.0,
            ),
            onCameraMove: onCameraMove,
            mapType: mapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId("najotTalim"),
                icon: BitmapDescriptor.defaultMarker,
                position: najotTalim,
                infoWindow: const InfoWindow(
                  title: "Najot Ta'lim",
                  snippet: "Xush kelibsiz",
                ),
              ),
              Marker(
                markerId: const MarkerId("myCurrentPosition"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                position: myCurrentPosition,
                infoWindow: const InfoWindow(
                  title: "Najot Ta'lim",
                  snippet: "Xush kelibsiz",
                ),
              ),
              ...myMarkers,
            },
            polylines: polylines,
          ),
          Positioned(
            top: 30,
            left: 16,
            right: 16,
            child: GooglePlacesAutoCompleteTextFormField(
                textEditingController: _textEditingController,
                googleAPIKey: "AIzaSyAkov3z_11fzOjlCygaO2e2LWZTqggk8QI",
                decoration: InputDecoration(
                  suffixIcon: TextButton(
                    onPressed: () {
                      _textEditingController.clear();
                    },
                    child: const Text(
                      "X",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (postalCodeResponse) {
                  // print("Coordinates: (${postalCodeResponse.lat},${postalCodeResponse.lng})");
                  double latitude = double.parse(postalCodeResponse.lat!);
                  double longitude = double.parse(postalCodeResponse.lng!);
                  // print(latitude);
                  myCurrentPosition = LatLng(latitude, longitude);
                  setState(() {
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: myCurrentPosition,
                          zoom: 16.0,
                        ),
                      ),
                    );
                  });
                },
                onChanged: (value) {
                  print(value);
                },
                itmClick: (prediction) {
                  _textEditingController.text = prediction.description!;
                  _textEditingController.selection = TextSelection.fromPosition(
                    TextPosition(
                      offset: prediction.description!.length,
                    ),
                  );
                }),
          ),
          Positioned(
            bottom: 100,
            right: 16,
            child: GestureDetector(
              onDoubleTap: () {
                mapController.animateCamera(
                  CameraUpdate.zoomOut(),
                );
              },
              onLongPress: () {
                mapController.animateCamera(
                  CameraUpdate.zoomIn(),
                );
              },
              onTap: _goToCurrentLocation,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 16,
            child: Row(
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.teal,
                  heroTag: "walking",
                  onPressed: () {
                    setState(() {
                      mapType = MapType.hybrid;
                    });
                  },
                  child: const Icon(
                    Icons.layers,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  backgroundColor: Colors.teal,
                  heroTag: "driving",
                  onPressed: () {
                    setState(() {
                      mapType = MapType.normal;
                    });
                  },
                  child: const Icon(
                    Icons.satellite,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  backgroundColor: Colors.teal,
                  heroTag: "bicycling",
                  onPressed: () {
                    setState(() {
                      mapType = MapType.terrain;
                    });
                  },
                  child: const Icon(
                    Icons.terrain,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: addLocationMarker,
      //   child: const Icon(Icons.add_location_alt_outlined),
      // ),
    );
  }
}
