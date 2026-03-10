import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnjood_vendor/features/auth/domain/models/prediction_model.dart';
import 'package:mnjood_vendor/features/order/controllers/address_controller.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

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
  // bool _firstTime = true;
  // late List<String> options = [];


  @override
  void initState() {
    super.initState();

    controller.text = widget.pickedLocation ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // if(_firstTime) {
    //   _search(widget.pickedLocation ?? '');
    //   _firstTime = false;
    // }
    if(controller.isAttached && !controller.isOpen) {
      controller.text = widget.pickedLocation ?? '';
    }
    return GetBuilder<AddressController>(
      builder: (addressController) {
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
            // options = (await _search(value, addressController)).toList();
          },
          viewConstraints: const BoxConstraints(minHeight: 100 , maxHeight: 300),

          builder: (BuildContext context, SearchController controller) {
            return widget.child ?? Container(
              height: 50, width: 500,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
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

                const Icon(HeroiconsOutline.magnifyingGlass),
              ]),
            );
          },
          suggestionsBuilder: (BuildContext context, SearchController controller) async {
            _searchingWithQuery = controller.text;
            final List<String> options = (await _search(_searchingWithQuery!, addressController)).toList();
            if (_searchingWithQuery != controller.text) {
              return _lastOptions;
            }

            _lastOptions = List<ListTile>.generate(options.length, (int index) {
              final String location = options[index];
              return ListTile(
                leading: const Icon(HeroiconsOutline.mapPin),
                title: Text(location),
                onTap: () async {
                  int selectedIndex = _predictList.indexOf(location);
                  PredictionModel suggestion = _predictionList[selectedIndex];
                  Position position = await Get.find<AddressController>().setLocation(suggestion.placeId!, suggestion.description, widget.mapController);
                  if(widget.fromAddress!) {
                    widget.callBack!(position);
                  }
                  controller.closeView(location);
                },
              );
            });

            return _lastOptions;
          });
      }
    );

  }

  Future<Iterable<String>> _search(String query, AddressController addressController) async {
    _predictionList = await addressController.searchLocation(query);
    
    if (query == '') {
      return const Iterable<String>.empty();
    }
    _predictList = [];
    for (var prediction in _predictionList) {
      _predictList.add(prediction.description!);
    }
    if(_predictList.isEmpty) {
      _predictList.add('no_address_found'.tr);
    }
    return _predictList;
  }
}
