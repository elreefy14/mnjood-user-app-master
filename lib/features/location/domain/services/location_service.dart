import 'package:mnjood/features/location/domain/models/prediction_model.dart';
import 'package:mnjood/features/location/domain/models/zone_response_model.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/location/domain/reposotories/location_repo_interface.dart';
import 'package:mnjood/features/location/domain/services/location_service_interface.dart';
import 'package:mnjood/features/location/widgets/permission_dialog.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnjood/util/app_constants.dart';

class LocationService implements LocationServiceInterface{
  final LocationRepoInterface locationRepoInterface;
  LocationService({required this.locationRepoInterface});

  @override
  Future<Position> getPosition(LatLng? defaultLatLng, LatLng configLatLng) async {
    Position myPosition;
    try {
      await Geolocator.requestPermission();
      // Use high accuracy for better GPS results
      Position newLocalData = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Validate position is within Saudi Arabia bounds
      // Saudi Arabia approximate bounds: Lat 16.0-33.0, Lng 34.0-56.0
      if (_isWithinSaudiArabia(newLocalData.latitude, newLocalData.longitude)) {
        myPosition = newLocalData;
      } else {
        // Outside Saudi Arabia - use default or config location
        myPosition = _createDefaultPosition(defaultLatLng, configLatLng);
        showCustomSnackBar('location_outside_service_area'.tr);
      }
    } catch(e) {
      myPosition = _createDefaultPosition(defaultLatLng, configLatLng);
    }
    return myPosition;
  }

  /// Check if coordinates are within Saudi Arabia bounds
  bool _isWithinSaudiArabia(double lat, double lng) {
    // Saudi Arabia approximate bounds
    const double minLat = 16.0;
    const double maxLat = 33.0;
    const double minLng = 34.0;
    const double maxLng = 56.0;

    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }

  /// Create a default position from provided coordinates
  Position _createDefaultPosition(LatLng? defaultLatLng, LatLng configLatLng) {
    return Position(
      latitude: defaultLatLng?.latitude ?? configLatLng.latitude,
      longitude: defaultLatLng?.longitude ?? configLatLng.longitude,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );
  }

  @override
  Future<ZoneResponseModel> getZone(String? lat, String? lng) async {
    return await locationRepoInterface.getZone(lat, lng);
  }

  @override
  void handleTopicSubscription(AddressModel? savedAddress, AddressModel? address) {
    if(!GetPlatform.isWeb) {
      final configModel = Get.find<SplashController>().configModel;
      if(configModel?.demo == true) {
        FirebaseMessaging.instance.subscribeToTopic(AppConstants.demoResetTopic);
      } else {
        FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.demoResetTopic);
      }
      if (savedAddress != null) {
        if(savedAddress.zoneIds != null) {
          for(int zoneID in savedAddress.zoneIds!) {
            FirebaseMessaging.instance.unsubscribeFromTopic('zone_${zoneID}_customer');
          }
        }else {
          FirebaseMessaging.instance.unsubscribeFromTopic('zone_${savedAddress.zoneId}_customer');
        }
      } else {
        FirebaseMessaging.instance.subscribeToTopic('zone_${address!.zoneId}_customer');
      }
      if(address!.zoneIds != null) {
        for(int zoneID in address.zoneIds!) {
          FirebaseMessaging.instance.subscribeToTopic('zone_${zoneID}_customer');
        }
      }else {
        FirebaseMessaging.instance.subscribeToTopic('zone_${address.zoneId}_customer');
      }
    }
  }

  @override
  Future<LatLng> getLatLng(String id) async {
    LatLng latLng = const LatLng(0, 0);
    Response? response = await locationRepoInterface.get(id);
    if(response?.statusCode == 200) {
      var data = response?.body;
      // Handle V3 API wrapper
      if (data != null && data['data'] != null) {
        data = data['data'];
      }
      // Get location from nested 'location' object or root level
      final location = data?['location'] ?? data;
      if (location != null) {
        // Handle both 'latitude'/'longitude' and 'lat'/'lng' field names
        final double lat = (location['latitude'] ?? location['lat'] ?? 0).toDouble();
        final double lng = (location['longitude'] ?? location['lng'] ?? 0).toDouble();
        if (lat != 0 && lng != 0) {
          latLng = LatLng(lat, lng);
        }
      }
    }
    return latLng;
  }

  @override
  Future<String> getAddressFromGeocode(LatLng latLng) async {
    return await locationRepoInterface.getAddressFromGeocode(latLng);
  }

  @override
  Future<List<PredictionModel>> searchLocation(String text) async {
    List<PredictionModel> predictionList = [];
    Response response = await locationRepoInterface.searchLocation(text);
    if (response.statusCode == 200) {
      predictionList = [];
      // Handle V3 API response format with 'data' wrapper
      var responseData = response.body;
      if (responseData['data'] != null) {
        responseData = responseData['data'];
      }
      // Try 'suggestions' first, then 'predictions' for backward compatibility
      var suggestions = responseData['suggestions'] ?? responseData['predictions'] ?? [];
      if (suggestions is List) {
        for (var prediction in suggestions) {
          predictionList.add(PredictionModel.fromJson(prediction));
        }
      }
    } else if (response.statusCode == 404) {
      // API not found - likely endpoint issue, don't show error to user
      print('Location search endpoint not found');
    } else {
      // Only show error for non-200/404 responses
      var errorMessage = response.body?['error']?['message'] ??
          response.body?['error_message'] ??
          'search_failed'.tr;
      showCustomSnackBar(errorMessage);
    }
    return predictionList;
  }

  @override
  void checkLocationPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    }else {
      onTap();
    }
  }

  @override
  void handleRoute(bool fromSignUp, String? route, bool canRoute) {
    if(fromSignUp) {
      Get.offAllNamed(RouteHelper.getInterestRoute());
    }else {
      if(route != null && canRoute) {
        Get.offAllNamed(route);
      } else {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    }
  }

  @override
  void handleMapAnimation(GoogleMapController? mapController, Position myPosition) {
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(myPosition.latitude, myPosition.longitude), zoom: 16),
      ));
    }
  }

  @override
  Future<void> updateZone() async {
     await locationRepoInterface.updateZone();
  }

}