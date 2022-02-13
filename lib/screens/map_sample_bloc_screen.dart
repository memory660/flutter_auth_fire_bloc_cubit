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
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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

  List flxArrInit = [1, 5, 4];
  List flxArrOpen = [6, 0, 4];
  List flxArr = [1, 5, 4];

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
                      Expanded(
                        flex: flxArr[0],
                        child: Container(child: searchSection()),
                      ),
                      Expanded(
                        flex: flxArr[1],
                        child: Container(
                          child: googleMapSection(),
                        ),
                      ),
                      Expanded(
                        flex: flxArr[2],
                        child: markersSectionBloc(context, state),
                      ),
                    ],
                  );
                })),
      ),
    );
  }

  Column searchSection() {
    return Column(children: [
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
            visible: predictionsList.isNotEmpty && addressVisibility,
            child: autocompleteSearchsection(context, predictionsList),
          );
        },
      )
    ]);
  }

  Container autocompleteSearchsection(ctx, predictionsList) {
    return Container(
        width: 100.0.w,
        height: 300,
        child: Builder(
            builder: (context) => Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      backgroundBlendMode: BlendMode.darken),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ListView.separated(
                    controller: ScrollController(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          getPlaceAddressDetails(
                              ctx, predictionsList[index].placeID);
                          setState(() {
                            addressVisibility = false;
                            flxArr = flxArrInit;
                            setState(() {});
                          });
                        },
                        title: Text(
                          predictionsList[index].mainText,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                        subtitle: Text(
                          predictionsList[index].secondaryText,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
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
                )));
  }

  Visibility googleMapSection() {
    return Visibility(
        visible: !addressVisibility,
        maintainState: true,
        child: Container(
          height: 100.0.h,
          width: 100.0.w,
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
        ));
  }

  Container markersSectionBloc(ctx, state) {
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
        width: 100.0.w,
        height: 100.0.h,
        child: ListView.builder(
            itemCount: state.markers.length,
            itemBuilder: (BuildContext context, int index) {
              final list = state.markers.toList(growable: true);

              return Dismissible(
                  background: Container(color: Colors.red),
                  key: ValueKey<Object>(list),
                  onDismissed: (direction) {
                    removeMarker(ctx, list[index]);
                  },
                  child: GestureDetector(
                    onTap: () {
                      final marker = list[index];
                      final ProjectMapModel selectedPlace = ProjectMapModel(
                          marker.markerId.value,
                          marker.position.latitude,
                          marker.position.longitude,
                          marker.infoWindow.title.toString());
                      destinationLocation = selectedPlace;
                      destinationController.text = selectedPlace.name;
                      animateCameraNewLatLng(selectedPlace);
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.album),
                            title:
                                Text(list[index].infoWindow.title.toString()),
                            subtitle: Text("ID: " +
                                list[index].markerId.value.toString() +
                                "\nLat: " +
                                list[index].position.latitude.toString() +
                                "  Lng: " +
                                list[index].position.longitude.toString()),
                          ),
                        ],
                      ),
                    ),
                  ));
            }));
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

  void findPlace(String inputPlace) async {
    if (inputPlace.length > 1) {
      final String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputPlace&key=$API_KEY&sessiontoken=1234567890&components=country:fr";
      final result = await ApiService.getRequest(autoCompleteUrl);
      listenablePlaceModels.value = (result["predictions"] as List)
          .map((e) => PlaceModel.fromJson(e))
          .toList();
      if (listenablePlaceModels.value.isNotEmpty) {
        addressVisibility = true;
        flxArr = flxArrOpen;
        setState(() {});

        return;
      }
    }
    addressVisibility = false;
    flxArr = flxArrInit;
    setState(() {});
  }
}
