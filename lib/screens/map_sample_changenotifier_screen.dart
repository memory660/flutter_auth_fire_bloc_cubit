import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_project4/map_api_key.dart';
import 'package:flutter_project4/models/google_maps_model.dart';
import 'package:flutter_project4/models/place_model.dart';
import 'package:flutter_project4/models/project_maps_model.dart';
import 'package:flutter_project4/screens/widgets/appbar_widget.dart';
import 'package:flutter_project4/screens/widgets/search_text_field.dart';
import 'package:flutter_project4/services/api_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

enum LocationStatus { SEARCHING, FOUND, ERROR }

class MapSampleChangeNotifierScreen extends StatefulWidget {
  const MapSampleChangeNotifierScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MapSampleChangeNotifierScreen> createState() =>
      MapSampleChangeNotifierScreenState();
}

class MapSampleChangeNotifierScreenState
    extends State<MapSampleChangeNotifierScreen> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kLake = CameraPosition(
    target: LatLng(37.43296265331129, -122.08832357078792),
  );

  // -----------------------------------------
  // -----------------------------------------
  final TextEditingController destinationController = TextEditingController();
  ValueNotifier<List<PlaceModel>> listenablePlaceModels =
      ValueNotifier<List<PlaceModel>>([]);
  late ProjectMapModel destinationLocation;
  late GoogleMapController mapController;

  bool autocompleteVisibility = false;

  late GoogleMapsModel markerModel;
  MarkerId? markerId;

  late Position currentPosition;
  final TextEditingController locationController = TextEditingController();
  ValueNotifier<LocationStatus> listenableStatus =
      ValueNotifier<LocationStatus>(LocationStatus.SEARCHING);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarWidget(height: 50, title: 'notifier maps'),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          SearchTextField(
            controller: destinationController,
            onChanged: (text) {
              findPlace(text);
            },
            onSubmitted: (text) {},
          ),
          ValueListenableBuilder<List<PlaceModel>>(
            valueListenable: listenablePlaceModels,
            builder: (context, predictionsList, child) {
              return Visibility(
                visible: predictionsList.isNotEmpty && autocompleteVisibility,
                child: autocompleteSearchsection(predictionsList),
              );
            },
          ),
          googleMapSection(),
          markersSection(),
        ],
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  // --------------------------------------------
  getPlaceAddressDetails(String placeID) async {
    final String placeAddressDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$API_KEY";
    final result = await ApiService.getRequest(placeAddressDetailsUrl);
    final location = result["result"]["geometry"]["location"];
    final ProjectMapModel selectedPlace = ProjectMapModel(
        placeID, location["lat"], location["lng"], result["result"]["name"]);
    destinationLocation = selectedPlace;
    destinationController.text = selectedPlace.name;
    animateCameraNewLatLng(selectedPlace);
    addMarker(selectedPlace);
  }

  void animateCameraNewLatLng(ProjectMapModel work) {
    mapController.animateCamera(CameraUpdate.newLatLng(work.latLong));
  }

  addMarker(ProjectMapModel place) {
    markerModel = Provider.of<GoogleMapsModel>(context, listen: false);
    //if (null != markerId) markerModel.deleteMarker(markerId!);
    markerId = markerModel.addMarker(place);
  }

  removeMarker(Marker marker) {
    markerModel.deleteMarker(marker.markerId);
  }

  findPlace(String inputPlace) async {
    if (inputPlace.length > 1) {
      final String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputPlace&key=$API_KEY&sessiontoken=1234567890&components=country:fr";
      final result = await ApiService.getRequest(autoCompleteUrl);
      listenablePlaceModels.value = (result["predictions"] as List)
          .map((e) => PlaceModel.fromJson(e))
          .toList();
      if (listenablePlaceModels.value.isNotEmpty) {
        autocompleteVisibility = true;
      }
    }
  }

  Builder autocompleteSearchsection(predictionsList) {
    return Builder(
        builder: (context) => Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  backgroundBlendMode: BlendMode.darken),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: 370,
              height: 370,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      getPlaceAddressDetails(predictionsList[index].placeID);
                      setState(() {
                        autocompleteVisibility = false;
                      });
                    },
                    title: Text(
                      predictionsList[index].mainText,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    subtitle: Text(
                      predictionsList[index].secondaryText,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    leading: const Icon(
                      Icons.add_location,
                      color: Colors.white,
                    ),
                  );
                },
                itemCount: predictionsList.length,
                separatorBuilder: (context, index) {
                  return const Divider(height: 1, color: Colors.grey);
                },
              ),
            ));
  }

  Container googleMapSection() {
    return Container(
      height: 300,
      width: 600,
      child: Consumer<GoogleMapsModel>(
        builder: (context, mapModel, child) {
          return GoogleMap(
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            mapType: MapType.normal,
            polylines: mapModel.polylineSet,
            initialCameraPosition: CameraPosition(
                target: LatLng(44.85748824841539, -0.509009242633116),
                zoom: 15),
            onMapCreated: (map) {
              mapController = map;
            },
            markers: mapModel.markerMap.isNotEmpty
                ? Set<Marker>.of(mapModel.markerMap.values)
                : Set<Marker>(),
            onTap: (LatLng latLng) {
              print(latLng);
            },
          );
        },
      ),
    );
  }

  Container markersSection() {
    return Container(
      height: 300,
      width: 600,
      child: Consumer<GoogleMapsModel>(
        builder: (context, mapModel, child) {
          return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: mapModel.markerMap.length,
              itemBuilder: (BuildContext context, int index) {
                final list = mapModel.markerMap.values.toList(growable: true);
                return Container(
                    height: 100,
                    child: Center(
                        child: Dismissible(
                            background: Container(color: Colors.red),
                            key: ValueKey<Object>(list),
                            onDismissed: (direction) {
                              removeMarker(list[index]);
                            },
                            child: GestureDetector(
                              onTap: () {
                                final marker = list[index];
                                final ProjectMapModel selectedPlace =
                                    ProjectMapModel(
                                        marker.markerId.value,
                                        marker.position.latitude,
                                        marker.position.longitude,
                                        marker.infoWindow.title.toString());
                                destinationLocation = selectedPlace;
                                destinationController.text = selectedPlace.name;
                                animateCameraNewLatLng(selectedPlace);
                                addMarker(selectedPlace);
                              },
                              child: Card(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.album),
                                      title: Text(list[index]
                                          .infoWindow
                                          .title
                                          .toString()),
                                      subtitle: Text("ID: " +
                                          list[index]
                                              .markerId
                                              .value
                                              .toString() +
                                          "\nLat: " +
                                          list[index]
                                              .position
                                              .latitude
                                              .toString() +
                                          "  Lng: " +
                                          list[index]
                                              .position
                                              .longitude
                                              .toString()),
                                    ),
                                  ],
                                ),
                              ),
                            ))));
              });
        },
      ),
    );
  }
}
