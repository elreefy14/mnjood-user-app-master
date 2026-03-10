import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/features/location/domain/models/prediction_model.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class LocationSearchDialog extends StatefulWidget {
  final GoogleMapController? mapController;
  final String? pickedLocation;
  final Widget? child;
  final Function(Position)? callBack;
  final bool? fromAddress;
  const LocationSearchDialog({super.key, required this.mapController, this.pickedLocation, this.child, this.callBack, this.fromAddress = false});

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final SearchController controller = SearchController();
  String? _searchingWithQuery;
  late Iterable<Widget> _lastOptions = <Widget>[];
  List<PredictionModel> _predictionList = [];
  List<String> _predictList = <String>[];
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();

    controller.text = widget.pickedLocation ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if(controller.isAttached && !controller.isOpen) {
      controller.text = widget.pickedLocation ?? '';
    }
    return GetBuilder<LocationController>(
      builder: (lController) {
        return SearchAnchor(
          searchController: controller,
          viewSurfaceTintColor: Theme.of(context).cardColor,
          isFullScreen: false,
          viewLeading: IconButton(onPressed: () => controller.closeView(''), icon: const Icon(HeroiconsOutline.arrowLeft)),
          viewTrailing: [
            IconButton(
              onPressed: () {
                if(controller.text.isNotEmpty) {
                  controller.text = '';
                } else {
                  controller.closeView('');
                }
              },
              icon: const Icon(HeroiconsOutline.xMark),
            ),
          ],
          viewOnChanged: (value) async {

          },
          viewConstraints: const BoxConstraints(minHeight: 100 , maxHeight: 300),

          builder: (BuildContext context, SearchController controller) {
            return widget.child ?? Container(
              height: 50, width: 500,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Row(children: [

                Icon(HeroiconsOutline.mapPin, size: 25, color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Text(
                  controller.text.isNotEmpty ? controller.text : 'search_location'.tr,
                  style: robotoRegular.copyWith(color: controller.text.isEmpty ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyMedium!.color),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),

                Icon(HeroiconsOutline.magnifyingGlass, color: Theme.of(context).disabledColor),
              ]),
            );
          },
          suggestionsBuilder: (BuildContext context, SearchController controller) async {
            _searchingWithQuery = controller.text;
            final List<String> options = (await _search(_searchingWithQuery!, lController)).toList();
            if (_searchingWithQuery != controller.text) {
              return _lastOptions;
            }

            _lastOptions = List<ListTile>.generate(options.length, (int index) {
              final String location = options[index];
              // Check if this is a "no results" message (not a real location)
              final bool isNoResultsMessage = _predictionList.isEmpty;

              return ListTile(
                leading: Icon(
                  isNoResultsMessage ? HeroiconsOutline.informationCircle : HeroiconsOutline.mapPin,
                  color: isNoResultsMessage ? Theme.of(context).hintColor : null,
                ),
                title: Text(
                  location,
                  style: isNoResultsMessage
                      ? TextStyle(color: Theme.of(context).hintColor, fontStyle: FontStyle.italic)
                      : null,
                ),
                onTap: isNoResultsMessage ? null : () async {
                  int selectedIndex = _predictList.indexOf(location);
                  if (selectedIndex >= 0 && selectedIndex < _predictionList.length) {
                    PredictionModel suggestion = _predictionList[selectedIndex];
                    Position position = await Get.find<LocationController>().setLocation(suggestion.placeId!, suggestion.description, widget.mapController);
                    if(widget.fromAddress!) {
                      widget.callBack!(position);
                    }
                    controller.closeView(location);
                  }
                },
              );
            });

            return _lastOptions;
          });
      }
    );

  }

  Future<Iterable<String>> _search(String query, LocationController locationController) async {
    _predictionList = await locationController.searchLocation(query);

    if (query == '') {
      return const Iterable<String>.empty();
    }
    _predictList = [];
    for (var prediction in _predictionList) {
      _predictList.add(prediction.description!);
    }
    if(_predictList.isEmpty) {
      // Show message that service is only available in Saudi Arabia
      _predictList.add('service_available_in_saudi_arabia_only'.tr);
    }
    return _predictList;
  }
}
