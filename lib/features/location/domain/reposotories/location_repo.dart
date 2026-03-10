import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/location/domain/models/zone_response_model.dart';
import 'package:mnjood/features/address/domain/models/zone_model.dart';
import 'package:mnjood/features/location/domain/reposotories/location_repo_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationRepo implements LocationRepoInterface {
  final ApiClient apiClient;
  LocationRepo({required this.apiClient});

  @override
  Future<ZoneResponseModel> getZone(String? lat, String? lng) async {
    Response response = await apiClient.getData('${AppConstants.zoneUri}?lat=$lat&lng=$lng', handleError: false);
    if(response.statusCode == 200) {
      ZoneResponseModel responseModel;
      // Handle V3 API response wrapper
      var responseData = response.body['data'] ?? response.body;

      List<int> zoneIds = [];
      List<ZoneData> zoneData = [];

      // V3 format: data is an array of zone objects
      if (responseData is List) {
        for (var zone in responseData) {
          if (zone['id'] != null) {
            zoneIds.add(zone['id'] is int ? zone['id'] : int.parse(zone['id'].toString()));
          }
          // Create ZoneData from V3 format — include all shipping charge fields
          zoneData.add(ZoneData(
            id: zone['id'],
            status: zone['status'] == true || zone['status'] == 1 ? 1 : 0,
            perKmShippingCharge: zone['per_km_shipping_charge']?.toDouble(),
            minimumShippingCharge: zone['minimum_shipping_charge']?.toDouble(),
            maximumShippingCharge: zone['maximum_shipping_charge']?.toDouble(),
            increasedDeliveryFee: zone['increased_delivery_fee']?.toDouble(),
            increasedDeliveryFeeStatus: zone['increased_delivery_fee_status'],
            increaseDeliveryFeeMessage: zone['increase_delivery_charge_message'],
            maxCodOrderAmount: zone['max_cod_order_amount']?.toDouble(),
          ));
        }
      } else {
        // V1 format: use ZoneModel
        ZoneModel zoneModel = ZoneModel.fromJson(responseData);
        zoneIds = zoneModel.zoneIds ?? [];
        zoneData = zoneModel.zoneData ?? [];
      }

      // Return failure if no zones found for this location
      if (zoneIds.isEmpty) {
        return ZoneResponseModel(false, 'No delivery zones found for this location', [], []);
      }
      responseModel = ZoneResponseModel(true, '', zoneIds, zoneData);
      return responseModel;
    } else {
      return ZoneResponseModel(false, response.statusText ?? 'Zone not found', [], []);
    }
  }

  @override
  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response = await apiClient.getData(
      '${AppConstants.geocodeUri}?lat=${latLng.latitude}&lng=${latLng.longitude}',
      handleError: false,
    );
    String address = 'Unknown Location';

    if(response.statusCode == 200 && response.body != null) {
      try {
        var body = response.body;

        // Format 1: Google Maps format - {status: "OK", results: [{formatted_address: "..."}]}
        if (body['status'] == 'OK' && body['results'] != null) {
          var results = body['results'];
          if (results is List && results.isNotEmpty) {
            address = results[0]['formatted_address']?.toString() ?? address;
          }
        }
        // Format 2: Direct address field - {address: "..."} or {formatted_address: "..."}
        else if (body['address'] != null) {
          address = body['address'].toString();
        }
        else if (body['formatted_address'] != null) {
          address = body['formatted_address'].toString();
        }
        // Format 3: V3 API wrapper - {data: {address: "..."}}
        else if (body['data'] != null) {
          var data = body['data'];
          if (data is Map) {
            address = data['address']?.toString()
                ?? data['formatted_address']?.toString()
                ?? address;
          } else if (data is String) {
            address = data;
          }
        }
        // Format 4: Direct string response
        else if (body is String && body.isNotEmpty) {
          address = body;
        }
      } catch (e) {
        print('Geocode parsing error: $e');
      }
    }
    // Don't show snackbar on 404 - just return fallback address silently
    return address;
  }

  // @override
  // Future<dynamic> get({LatLng? latLng, bool isZone = false}) {
  //   if(isZone) {
  //     _getZone(latLng!.latitude.toString(), latLng.longitude.toString());
  //   } else {
  //     _getAddressFromGeocode(latLng!);
  //   }
  // }


  @override
  Future<Response> searchLocation(String text) async {
    return await apiClient.getData('${AppConstants.searchLocationUri}?search_text=$text');
  }

  Future<Response> getById(int id) async {
    Response response = await apiClient.getData('${AppConstants.placeDetailsUri}?placeid=$id');
    return response;
  }

  @override
  Future<Response> updateZone() async {
    return await apiClient.getData(AppConstants.updateZoneUri);
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Response> get(String? id) async {
    Response response = await apiClient.getData('${AppConstants.placeDetailsUri}?placeid=$id');
    return response;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}
