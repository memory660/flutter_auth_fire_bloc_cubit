import 'package:flutter_project4/screens/bloc/gmaps/markers_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MarkersEvent {}

class MarkersRequested extends MarkersEvent {}

class MarkersUpdate extends MarkersEvent {
  MarkersUpdate({required this.marker});

  final Marker marker;
}

class MarkersAdd extends MarkersEvent {
  MarkersAdd({required this.marker});

  final Marker marker;

  @override
  List<Object?> get props => [marker];
}

class MarkersDelete extends MarkersEvent {
  MarkersDelete({required this.markerId});

  final int markerId;
}
