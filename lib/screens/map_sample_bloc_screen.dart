import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/map_api_key.dart';
import 'package:flutter_project4/models/google_maps_model.dart';
import 'package:flutter_project4/models/place_model.dart';
import 'package:flutter_project4/models/project_maps_model.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_bloc.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_event.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_state.dart';
import 'package:flutter_project4/screens/widgets/appbar_widget.dart';
import 'package:flutter_project4/screens/widgets/markers_widget.dart';
import 'package:flutter_project4/screens/widgets/search_text_field.dart';

import 'package:flutter_project4/services/api_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppbarWidget(height: 50, title: 'bloc maps'),
        resizeToAvoidBottomInset: false,
        body: BlocProvider<MarkersBloc>(
            create: (context) => MarkersBloc(),
            child: Builder(
                builder: (context) => BlocBuilder<MarkersBloc, MarkersState>(
                    buildWhen: (previous, current) => current.status.isSuccess,
                    builder: (context, state) {
                      return Container(
                        child:
                            OrientationBuilder(builder: (context, orientation) {
                          print(orientation);
                          if (orientation == Orientation.portrait) {
                            return Container(
                              // Widget for Portrait

                              child: Content(
                                axe: Axis.vertical,
                                width: 1,
                                heightAuto: 1,
                                orientation: orientation,
                              ),
                            );
                          } else {
                            return Container(
                              // Widget for Landscape

                              child: Content(
                                axe: Axis.horizontal,
                                width: 1,
                                heightAuto: 1,
                                orientation: orientation,
                              ),
                            );
                          }
                        }),
                      );
                    }))));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}

class Content extends StatefulWidget {
  Content(
      {Key? key,
      required this.axe,
      required this.width,
      required this.heightAuto,
      required this.orientation})
      : super(key: key);
  final Axis axe;
  final double width;
  final double heightAuto;
  final Orientation orientation;

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late ProjectMapModel destinationLocation;
  late GoogleMapController mapController;
  bool autocompleteVisibility = false;

  final TextEditingController destinationController = TextEditingController();
  late GoogleMapsModel markerModel;
  MarkerId? markerId;
  ValueNotifier<List<PlaceModel>> listenablePlaceModels =
      ValueNotifier<List<PlaceModel>>([]);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = 0;
    double h = 0;
    double maph = 0;
    print(widget.axe);
    if (widget.axe == Axis.vertical) {
      w = 100.w;
      h = 100.h / 2;
      maph = 50;
    } else {
      w = 100.w / 2;
      h = 100.h;
      maph = 100;
    }
    return Flex(direction: widget.axe, children: <Widget>[
      Container(
        width: w,
        height: h,
        child: Column(children: [
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
                  visible: autocompleteVisibility,
                  child: Container(
                    width: w,
                    height: h - 80,
                    child: autocompleteSearchsection(context, predictionsList),
                  ));
            },
          ),
          Visibility(
              visible: !autocompleteVisibility,
              maintainState: true,
              child: Container(
                width: w,
                height: h - maph,
                child: googleMapSection(widget.orientation),
              )),
        ]),
      ),
      Container(
        width: w,
        height: h - 50,
        child: MarkersWidget(
          onMarkersChanged: (ProjectMapModel val) {
            initMarkers(context, val);
          },
        ),
      )
    ]);
  }

  Consumer googleMapSection(Orientation orientation) {
    return Consumer<GoogleMapsModel>(builder: (context, mapModel, child) {
      return GoogleMap(
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        mapType: MapType.normal,
        polylines: mapModel.polylineSet,
        initialCameraPosition: CameraPosition(
            target: LatLng(44.85748824841539, -0.509009242633116), zoom: 15),
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
    });
  }

  initMarkers(ctx, ProjectMapModel selectedPlace) {
    destinationLocation = selectedPlace;
    destinationController.text = selectedPlace.name;
    animateCameraNewLatLng(selectedPlace);
  }

  initPlace(ctx, ProjectMapModel selectedPlace) {
    destinationLocation = selectedPlace;
    destinationController.text = selectedPlace.name;

    animateCameraNewLatLng(selectedPlace);
    addMarker(ctx, selectedPlace);

    Marker marker = Marker(
        markerId: MarkerId(selectedPlace.placeID),
        position: selectedPlace.latLong,
        infoWindow: InfoWindow(title: selectedPlace.name));

    BlocProvider.of<MarkersBloc>(ctx, listen: false)
        .add(MarkersAdd(marker: marker));
  }

  void animateCameraNewLatLng(ProjectMapModel work) {
    mapController.animateCamera(CameraUpdate.newLatLng(work.latLong));
  }

  addMarker(ctx, ProjectMapModel place) {
    markerModel = Provider.of<GoogleMapsModel>(ctx, listen: false);
    markerId = markerModel.addMarker(place);
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
        autocompleteVisibility = true;
        setState(() {});
        return;
      }
    }

    autocompleteVisibility = false;
    setState(() {});
  }

  Visibility autocompleteSearchsection(ctx, predictionsList) {
    return Visibility(
        visible: autocompleteVisibility,
        child: Expanded(
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
                    ))));
  }

  getPlaceAddressDetails(ctx, String placeID) async {
    final String placeAddressDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$API_KEY";
    final result = await ApiService.getRequest(placeAddressDetailsUrl);
    final location = result["result"]["geometry"]["location"];
    final ProjectMapModel selectedPlace = ProjectMapModel(
        placeID, location["lat"], location["lng"], result["result"]["name"]);

    autocompleteVisibility = false;
    //animateCameraNewLatLng(selectedPlace);
    initPlace(ctx, selectedPlace);
    setState(() {});
  }
}
