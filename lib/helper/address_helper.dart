import 'dart:convert';

import 'package:mnjood/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/address/domain/models/address_model.dart';
import '../util/app_constants.dart';

class AddressHelper {
  static Future<bool> saveAddressInSharedPref(AddressModel address) async {
    try {
      SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
      String userAddress = jsonEncode(address.toJson());
      Get.find<ApiClient>().updateHeader(
        sharedPreferences.getString(AppConstants.token),
        address.zoneIds,
        sharedPreferences.getString(AppConstants.languageCode),
        address.latitude,
        address.longitude,
      );
      bool result = await sharedPreferences.setString(AppConstants.userAddress, userAddress);
      debugPrint('Address saved successfully: ${address.address}, zoneId: ${address.zoneId}');
      return result;
    } catch (e) {
      debugPrint('Error saving address: $e');
      return false;
    }
  }

  static AddressModel? getAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    AddressModel? addressModel;
    try {
      String? addressString = sharedPreferences.getString(AppConstants.userAddress);
      if (addressString != null && addressString.isNotEmpty) {
        addressModel = AddressModel.fromJson(jsonDecode(addressString));
        debugPrint('Address loaded successfully: ${addressModel.address}, zoneId: ${addressModel.zoneId}');
      } else {
        debugPrint('No address found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('Error loading address from SharedPreferences: $e');
    }
    return addressModel;
  }

  static bool clearAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    sharedPreferences.remove(AppConstants.userAddress);
    return true;
  }

}
