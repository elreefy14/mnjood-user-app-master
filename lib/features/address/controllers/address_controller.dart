import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/common/models/response_model.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/address/domain/services/address_service_interface.dart';
import 'package:get/get.dart';

class AddressController extends GetxController implements GetxService {
  final AddressServiceInterface addressServiceInterface;
  AddressController({required this.addressServiceInterface});

  List<AddressModel>? _addressList;
  late List<AddressModel> _allAddressList;
  List<AddressModel>? get addressList => _addressList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<ResponseModel> deleteAddress(int? id, int index) async {
    ResponseModel responseModel = await addressServiceInterface.delete(id!);
    if (responseModel.isSuccess) {
      _addressList!.removeAt(index);
    }
    update();
    return responseModel;
  }

  Future<void> getAddressList({bool canInsertAddress = false, DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _addressList = null;
    List<AddressModel>? addressList;

    if(dataSource == DataSourceEnum.local){
      addressList = await addressServiceInterface.getList(source: DataSourceEnum.local);
      _prepareAddressList(addressList, canInsertAddress: canInsertAddress);
      getAddressList(dataSource: DataSourceEnum.client);
    }else{
      addressList = await addressServiceInterface.getList(source: DataSourceEnum.client);
      _prepareAddressList(addressList, canInsertAddress: canInsertAddress);
    }
  }

  void _prepareAddressList(List<AddressModel>? addressList, {bool canInsertAddress = false}) {
    if (addressList != null) {
      _addressList = [];
      _allAddressList = [];
      // Remove duplicate addresses based on lat/lng before displaying
      List<AddressModel> uniqueAddresses = _removeDuplicateAddresses(addressList);
      _addressList?.addAll(uniqueAddresses);
      _allAddressList.addAll(uniqueAddresses);
      if (canInsertAddress) {
        Get.find<CheckoutController>().insertAddresses(null);
      }
    }
    update();
  }

  /// Removes duplicate addresses based on latitude/longitude coordinates
  /// Keeps the first occurrence (which has the earliest/original ID)
  List<AddressModel> _removeDuplicateAddresses(List<AddressModel> addresses) {
    final seen = <String>{};
    return addresses.where((addr) {
      final key = '${addr.latitude},${addr.longitude}';
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  Future<ResponseModel> addAddress(AddressModel addressModel, bool fromCheckout, int? restaurantZoneId) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await addressServiceInterface.add(addressModel, fromCheckout, restaurantZoneId);
    _isLoading = false;
    update();
    return responseModel;
  }

  // Future<bool> saveAddressLocally(AddressModel address) async {
  //   ResponseModel responseModel = await addressService.add(address);
  //   return responseModel.isSuccess;
  // }

  void filterAddresses(String queryText) {
    if (_addressList != null) {
      _addressList = addressServiceInterface.filterAddresses(_addressList!, queryText);
      update();
    }
  }

  Future<ResponseModel> updateAddress(AddressModel addressModel, int? addressId) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await addressServiceInterface.update(addressModel.toJson(), addressId!);
    if (responseModel.isSuccess) {
      Get.find<AddressController>().getAddressList();
    }
    _isLoading = false;
    update();
    return responseModel;
  }
}
