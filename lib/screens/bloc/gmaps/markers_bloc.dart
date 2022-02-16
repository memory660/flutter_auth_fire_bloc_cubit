import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_project4/models/google_maps_model.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_event.dart';
import 'package:flutter_project4/screens/bloc/gmaps/markers_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

class MarkersBloc extends Bloc<MarkersEvent, MarkersState> {
  MarkersBloc() : super(MarkersState()) {
    on<MarkersRequested>(_onMarkersRequested);
    on<MarkersUpdate>(_onMarkerUpdate);
    on<MarkersAdd>(_onMarkerAdd);
    on<MarkersDelete>(_onMarkerDelete);
  }

  //final MarkerRepo _repo = MarkerRepo();

  // remplace repo
  GoogleMapsModel mapsModel = GoogleMapsModel();

  Future<void> _onMarkersRequested(
    MarkersRequested event,
    Emitter<MarkersState> emit,
  ) async {
    emit(state.copyWith(status: MarkersStatus.loading));
    //final List<Marker> markers = await _repo.fetchMarkers();
    // remplace le repo [
    final markers = mapsModel.markerMap;
    List<Marker> markerlist = [];
    markers.forEach((k, v) => markerlist.add(v));
    // ]

    emit(state.copyWith(status: MarkersStatus.success, markers: markerlist));
  }

  Future<void> _onMarkerAdd(
    MarkersAdd event,
    Emitter<MarkersState> emit,
  ) async {
    emit(state.copyWith(status: MarkersStatus.loading));
    //final Marker marker = await _repo.addMarker(event.Marker);

    // remplace le repo [
    Marker marker = event.marker;
    // ]

    List<Marker> newList = List.from(state.markers)..add(marker);
    emit(
      state.copyWith(
        status: MarkersStatus.success,
        markers: newList,
      ),
    );
  }

  Future<void> _onMarkerUpdate(
    MarkersUpdate event,
    Emitter<MarkersState> emit,
  ) async {
    emit(state.copyWith(status: MarkersStatus.loading));
    //final Marker Marker = await _repo.editMarker(event.Marker);
    // remplace le repo [
    Marker marker = event.marker;
    // ]

    state.markers[state.markers
        .indexWhere((Marker p) => p.markerId == marker.markerId)] = marker;

    emit(
      state.copyWith(
        status: MarkersStatus.success,
        markers: state.markers,
      ),
    );
  }

  Future<void> _onMarkerDelete(
    MarkersDelete event,
    Emitter<MarkersState> emit,
  ) async {
    emit(state.copyWith(status: MarkersStatus.loading));
    state.markers.removeAt(
        state.markers.indexWhere((Marker p) => p.markerId == event.markerId));
    emit(
      state.copyWith(
        status: MarkersStatus.success,
        markers: state.markers,
      ),
    );
  }
}
