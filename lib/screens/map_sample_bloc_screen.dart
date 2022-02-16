import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/models/google_maps_model.dart';
import 'package:flutter_project4/models/place_model.dart';
import 'package:flutter_project4/models/project_maps_model.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_bloc.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_event.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_state.dart';
import 'package:flutter_project4/screens/widgets/markers_widget.dart';
import 'package:flutter_project4/screens/widgets/search_widget.dart';
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

  final TextEditingController destinationController = TextEditingController();
  late ProjectMapModel destinationLocation;
  late GoogleMapController mapController;
  bool addressVisibility = false;
  late GoogleMapsModel markerModel;
  MarkerId? markerId;
  List flxArr = [50, 50, (100.h / 2) - 50];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocProvider<MarkersBloc>(
            create: (context) => MarkersBloc(),
            child: Builder(
                builder: (context) => BlocBuilder<MarkersBloc, MarkersState>(
                    buildWhen: (previous, current) => current.status.isSuccess,
                    builder: (context, state) {
                      return Column(
                        children: [
                          SearchWidget(
                            height: flxArr[2],
                            onSelectedPlaceChanged: (ProjectMapModel val) {
                              initPlace(context, val);
                            },
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100.h / 2,
                            child: Container(
                              child: googleMapSection(),
                            ),
                          ),
                          Expanded(
                            child: MarkersWidget(
                              onMarkersChanged: (ProjectMapModel val) {
                                initMarkers(context, val);
                              },
                            ),
                          ),
                        ],
                      );
                    }))));
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
    addMarker(selectedPlace);

    Marker marker = Marker(
        markerId: MarkerId(selectedPlace.placeID),
        position: selectedPlace.latLong,
        infoWindow: InfoWindow(title: selectedPlace.name));

    BlocProvider.of<MarkersBloc>(ctx, listen: false)
        .add(MarkersAdd(marker: marker));
  }

  Visibility googleMapSection() {
    return Visibility(
      visible: !addressVisibility,
      maintainState: true,
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

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void animateCameraNewLatLng(ProjectMapModel work) {
    mapController.animateCamera(CameraUpdate.newLatLng(work.latLong));
  }

  addMarker(ProjectMapModel place) {
    markerModel = Provider.of<GoogleMapsModel>(context, listen: false);
    markerId = markerModel.addMarker(place);
  }
}
