import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/map_api_key.dart';
import 'package:flutter_project4/models/google_maps_model.dart';
import 'package:flutter_project4/models/place_model.dart';
import 'package:flutter_project4/models/project_maps_model.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_bloc.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_event.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_state.dart';
import 'package:flutter_project4/screens/widgets/search_text_field.dart';
import 'package:flutter_project4/services/api_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

enum LocationStatus { SEARCHING, FOUND, ERROR }

class MapSampleBlocScreen extends StatefulWidget {
  const MapSampleBlocScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MapSampleBlocScreen> createState() => MapSampleBlocScreenState();
}

class MapSampleBlocScreenState extends State<MapSampleBlocScreen> {
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

  bool addressVisibility = false;

  late GoogleMapsModel markerModel;
  MarkerId? markerId;

  late Position currentPosition;
  final TextEditingController locationController = TextEditingController();
  ValueNotifier<LocationStatus> listenableStatus =
      ValueNotifier<LocationStatus>(LocationStatus.SEARCHING);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider<MarkersBloc>(
      create: (context) => MarkersBloc(),
      child: Builder(
          builder: (context) => BlocBuilder<MarkersBloc, MarkersState>(
              buildWhen: (previous, current) => current.status.isSuccess,
              builder: (context, state) {
                return Column(
                  children: [
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
                          visible:
                              predictionsList.isNotEmpty && addressVisibility,
                          child: autocompleteSearchsection(
                              context, predictionsList),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    googleMapSection(),
                    const SizedBox(
                      height: 10,
                    ),
                    markersSectionBloc(context, state)
                  ],
                );
              })),
    ));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  // --------------------------------------------
  getPlaceAddressDetails(ctx, String placeID) async {
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

    Marker marker = Marker(
        markerId: MarkerId(selectedPlace.placeID),
        position: selectedPlace.latLong,
        infoWindow: InfoWindow(title: selectedPlace.name));

    BlocProvider.of<MarkersBloc>(ctx).add(MarkersAdd(marker: marker));
  }

  void animateCameraNewLatLng(ProjectMapModel work) {
    mapController.animateCamera(CameraUpdate.newLatLng(work.latLong));
  }

  addMarker(ProjectMapModel place) {
    markerModel = Provider.of<GoogleMapsModel>(context, listen: false);
    markerId = markerModel.addMarker(place);
  }

  removeMarker(ctx, Marker marker) {
    BlocProvider.of<MarkersBloc>(ctx)
        .add(MarkersDelete(markerId: marker.markerId));
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
        addressVisibility = true;
      }
    }
  }

  Builder autocompleteSearchsection(ctx, predictionsList) {
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
                      getPlaceAddressDetails(
                          ctx, predictionsList[index].placeID);
                      setState(() {
                        addressVisibility = false;
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

  Column markersSectionBloc(ctx, state) {
    return Column(
      children: [
        Container(
          margin:
              const EdgeInsets.only(top: 10, bottom: 10, left: 80, right: 80),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(ctx).size.width,
                    height: MediaQuery.of(ctx).size.height,
                    child: ListView.builder(
                        itemCount: state.markers.length,
                        itemBuilder: (BuildContext context, int index) {
                          final list = state.markers.toList(growable: true);

                          return Container(
                              child: Center(
                                  child: Dismissible(
                                      background: Container(color: Colors.red),
                                      key: ValueKey<Object>(list),
                                      onDismissed: (direction) {
                                        removeMarker(ctx, list[index]);
                                      },
                                      child: GestureDetector(
                                        onTap: () {
                                          final marker = list[index];
                                          final ProjectMapModel selectedPlace =
                                              ProjectMapModel(
                                                  marker.markerId.value,
                                                  marker.position.latitude,
                                                  marker.position.longitude,
                                                  marker.infoWindow.title
                                                      .toString());
                                          destinationLocation = selectedPlace;
                                          destinationController.text =
                                              selectedPlace.name;
                                          animateCameraNewLatLng(selectedPlace);
                                        },
                                        child: Card(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                leading:
                                                    const Icon(Icons.album),
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
                        }))
              ],
            ),
          ),
        )
      ],
    );
  }
}
