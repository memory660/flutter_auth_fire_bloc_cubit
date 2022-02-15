import 'package:flutter/material.dart';
import 'package:flutter_project4/map_api_key.dart';
import 'package:flutter_project4/models/place_model.dart';
import 'package:flutter_project4/models/project_maps_model.dart';
import 'package:flutter_project4/screens/functions/search_text_field.dart';
import 'package:flutter_project4/services/api_service.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget(
      {Key? key, required this.height, required this.onSelectedPlaceChanged})
      : super(key: key) {
    flxArr = [50, 50, height];
  }

  final double height;

  TextEditingController destinationController = TextEditingController();
  ValueNotifier<List<PlaceModel>> listenablePlaceModels =
      ValueNotifier<List<PlaceModel>>([]);
  bool addressVisibility = false;
  late List flxArr;
  late Function(ProjectMapModel) onSelectedPlaceChanged;

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
        //setState(() {});

        return;
      }
    }
    addressVisibility = false;
    flxArr[0] = flxArr[2];
    //setState(() {});
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

                          /*
                          setState(() {
                            addressVisibility = false;
                            flxArr[0] = flxArr[2];
                            setState(() {});
                          });
                          */
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
    print(location);
    final ProjectMapModel selectedPlace = ProjectMapModel(
        placeID, location["lat"], location["lng"], result["result"]["name"]);
    //
    print("------------------------");
    print(placeAddressDetailsUrl);
    print(selectedPlace);
    addressVisibility = false;
    flxArr[0] = flxArr[2];
    onSelectedPlaceChanged(selectedPlace);
  }
}
