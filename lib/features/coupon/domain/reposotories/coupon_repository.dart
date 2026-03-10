import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/coupon/domain/models/coupon_model.dart';
import 'package:mnjood/features/coupon/domain/models/customer_coupon_model.dart';
import 'package:mnjood/features/coupon/domain/reposotories/coupon_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect/connect.dart';

class CouponRepository implements CouponRepositoryInterface {
  final ApiClient apiClient;
  CouponRepository({required this.apiClient});

  @override
  Future<Response> applyCoupon({required String couponCode, int? restaurantID, double? orderAmount}) async {
    return await apiClient.getData('${AppConstants.couponApplyUri}$couponCode&restaurant_id=$restaurantID&order_amount=$orderAmount', handleError: true, showToaster: true);
  }

  @override
  Future<CustomerCouponModel?> getCouponList({int? customerId, int? restaurantId, int? orderRestaurantId, double? orderAmount}) async {
    CustomerCouponModel? customerCouponModel;
    Response response;

    if(orderRestaurantId != null && orderAmount != null) {
      response = await apiClient.getData('${AppConstants.couponUri}?${restaurantId != null ? 'restaurant_id' : 'customer_id'}=${restaurantId ?? customerId}&order_restaurant_id=$orderRestaurantId&order_amount=$orderAmount');
    }else {
      response = await apiClient.getData('${AppConstants.couponUri}?${restaurantId != null ? 'restaurant_id' : 'customer_id'}=${restaurantId ?? customerId}');
    }

    if(response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;

      // V3 API returns a flat list of coupons, while the model expects {available: [], unavailable: []}
      if(data is List) {
        // Convert flat list to expected format - treat all as available
        List<Coupon> availableCoupons = [];
        for (var coupon in data) {
          availableCoupons.add(Coupon.fromJson(coupon));
        }
        customerCouponModel = CustomerCouponModel(available: availableCoupons, unavailable: []);
      } else {
        // Original format with available/unavailable structure
        customerCouponModel = CustomerCouponModel.fromJson(data);
      }
    }
    return customerCouponModel;
  }

  @override
  Future<List<CouponModel>?> getRestaurantCouponList(int restaurantId, {String? vendorType}) async {
    List<CouponModel>? couponList;
    String vendorTypeParam = vendorType != null ? '&vendor_type=$vendorType' : '';
    Response response =  await apiClient.getData('${AppConstants.restaurantWiseCouponUri}?vendor_id=$restaurantId$vendorTypeParam');
    if(response.statusCode == 200) {
      couponList = [];
      // V3 API: Extract data array from response wrapper
      var dataArray = response.body['data'] ?? response.body;
      if(dataArray is List) {
        dataArray.forEach((category) {
          couponList!.add(CouponModel.fromJson(category));
        });
      }
    }
    return couponList;
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
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

}