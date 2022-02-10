import 'package:flutter/cupertino.dart';
import 'package:flutter_project4/models/project_maps_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsModel extends ChangeNotifier {
  Map<MarkerId, Marker> markerMap = Map<MarkerId, Marker>();
  Set<Polyline> polylineSet = {};
  Position currentPosition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  GoogleMapsModel() {
    fetchCurrentLocation().then((value) => () {
          currentPosition = value;
          print(value);
        });
  }

  addMarker(ProjectMapModel place) {
    final key = MarkerId(place.placeID);
    Map<MarkerId, Marker> markerMapMem = Map<MarkerId, Marker>();
    markerMapMem[key] = Marker(
      markerId: MarkerId(place.placeID),
      position: place.latLong,
      infoWindow: InfoWindow(title: place.name),
      onTap: () {
        print(place.placeID);
      },
    );
    markerMap.addAll(markerMapMem);
    notifyListeners();
    return key;
  }

  deleteMarker(MarkerId markerId) {
    markerMap.remove(markerId);
    notifyListeners();
  }

  addPolyline(Polyline polyline) {
    polylineSet.add(polyline);
    notifyListeners();
  }

  clearPolyline() {
    polylineSet.clear();
    notifyListeners();
  }

  ProjectMapModel currentLocation =
      ProjectMapModel("", 44.8233472, -0.4390912, "Bordeaux");

  Future<dynamic> fetchCurrentLocation() async {
    try {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      currentLocation = ProjectMapModel(
          "current_location",
          currentPosition.latitude,
          currentPosition.longitude,
          "Current Location");
      final List<Placemark> placemark = await placemarkFromCoordinates(
              currentPosition.latitude, currentPosition.longitude)
          .then((value) => value);
      notifyListeners();
      return currentPosition;
    } catch (e) {
      print(e);
    }
  }
}
