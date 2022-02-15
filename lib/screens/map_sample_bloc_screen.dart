import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/models/google_maps_model.dart';
import 'package:flutter_project4/models/place_model.dart';
import 'package:flutter_project4/models/project_maps_model.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_bloc.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_event.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_state.dart';
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
                        child: markersSectionBloc(context, state),
                      ),
                    ],
                  );
                })),
      ),
    );
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

    BlocProvider.of<MarkersBloc>(ctx).add(MarkersAdd(marker: marker));
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

  Container markersSectionBloc(ctx, state) {
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
        child: ListView.builder(
            shrinkWrap: true,
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
}
