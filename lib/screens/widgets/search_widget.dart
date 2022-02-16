import 'package:flutter/material.dart';
import 'package:flutter_project4/map_api_key.dart';
import 'package:flutter_project4/models/place_model.dart';
import 'package:flutter_project4/models/project_maps_model.dart';
import 'package:flutter_project4/screens/widgets/search_text_field.dart';
import 'package:flutter_project4/services/api_service.dart';

class SearchWidget extends StatefulWidget {
  SearchWidget(
      {Key? key, required this.height, required this.onSelectedPlaceChanged})
      : super(key: key);
  final double height;
  late Function(ProjectMapModel) onSelectedPlaceChanged;

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late double _height;
  late Function(ProjectMapModel) _onSelectedPlaceChanged;
  //
  TextEditingController destinationController = TextEditingController();
  ValueNotifier<List<PlaceModel>> listenablePlaceModels =
      ValueNotifier<List<PlaceModel>>([]);
  bool addressVisibility = false;
  late List flxArr;

  @override
  void initState() {
    super.initState();
    _onSelectedPlaceChanged = widget.onSelectedPlaceChanged;
    _height = widget.height;
    flxArr = [50, 50, _height];
  }

  @override
  Widget build(BuildContext context) {
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
        flxArr[0] = flxArr[1];
        return;
      }
    }
    addressVisibility = false;
    flxArr[0] = flxArr[2];
  }

  Container autocompleteSearchsection(ctx, predictionsList) {
    return Container(
        width: MediaQuery.of(ctx).size.width,
        height: flxArr[2],
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
                )));
  }

  getPlaceAddressDetails(ctx, String placeID) async {
    final String placeAddressDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$API_KEY";
    final result = await ApiService.getRequest(placeAddressDetailsUrl);
    final location = result["result"]["geometry"]["location"];
    final ProjectMapModel selectedPlace = ProjectMapModel(
        placeID, location["lat"], location["lng"], result["result"]["name"]);
    addressVisibility = false;
    flxArr[0] = flxArr[2];
    _onSelectedPlaceChanged(selectedPlace);
    setState(() {});
  }
}
