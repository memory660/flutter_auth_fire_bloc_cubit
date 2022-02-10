import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MarkersStatus { initial, success, error, loading, selected }

extension CategoryStatusX on MarkersStatus {
  bool get isInitial => this == MarkersStatus.initial;
  bool get isSuccess => this == MarkersStatus.success;
  bool get isError => this == MarkersStatus.error;
  bool get isLoading => this == MarkersStatus.loading;
  bool get isSelected => this == MarkersStatus.selected;
}

class MarkersState extends Equatable {
  const MarkersState({
    this.markers = const <Marker>[],
    this.isMax = false,
    this.status = MarkersStatus.initial,
  });

  final List<Marker> markers;
  final bool isMax;
  final MarkersStatus status;

  MarkersState copyWith({
    List<Marker>? markers,
    bool? isMax,
    MarkersStatus? status,
  }) {
    return MarkersState(
      markers: markers ?? this.markers,
      isMax: isMax ?? this.isMax,
      status: status ?? this.status,
    );
  }

  @override
  // TODO: implement props
  List<Object> get props => [markers, isMax, status];
}
