class PlaceModel {
  late String mainText;
  late String secondaryText;
  late String placeID;
  late List<dynamic> types;

  PlaceModel(this.mainText, this.secondaryText, this.placeID, this.types);

  PlaceModel.fromJson(Map<String, dynamic> json) {
    mainText = json["structured_formatting"]["main_text"];
    secondaryText = json["structured_formatting"]["secondary_text"];
    placeID = json["place_id"];
    types = json["types"];
  }

  @override
  String toString() {
    return 'PlaceModel{mainText: $mainText, secondaryText: $secondaryText, placeID: $placeID, types: $types}';
  }
}
