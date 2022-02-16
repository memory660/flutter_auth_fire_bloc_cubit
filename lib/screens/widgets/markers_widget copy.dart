import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/models/project_maps_model.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_bloc.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_event.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkersWidget extends StatelessWidget {
  MarkersWidget({Key? key, required this.onMarkersChanged}) : super(key: key);
  late Function(ProjectMapModel) onMarkersChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MarkersBloc>(
      create: (context) => MarkersBloc(),
      child: Builder(
          builder: (context) => BlocBuilder<MarkersBloc, MarkersState>(
              buildWhen: (previous, current) => current.status.isSuccess,
              builder: (context, state) {
                return Container(
                    margin: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 5, right: 5),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.markers.length,
                        itemBuilder: (BuildContext context, int index) {
                          final list = state.markers.toList(growable: true);

                          return Dismissible(
                              background: Container(color: Colors.red),
                              key: ValueKey<Object>(list),
                              onDismissed: (direction) {
                                removeMarker(context, list[index]);
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
                                  //
                                  onMarkersChanged(selectedPlace);
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
                              ));
                        }));
              })),
    );
  }

  removeMarker(ctx, Marker marker) {
    BlocProvider.of<MarkersBloc>(ctx)
        .add(MarkersDelete(markerId: marker.markerId));
  }
}
