import 'package:mnjood_vendor/common/models/response_model.dart';
import 'package:mnjood_vendor/features/order/domain/models/place_order_model.dart';
import 'package:mnjood_vendor/interface/repository_interface.dart';
import 'package:mnjood_vendor/features/order/domain/models/cart_model.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';

abstract class OrderEditRepositoryInterface implements RepositoryInterface {
  Future<ProductModel?> getSearchProduct({required int offset, required String productName});
  void addToSharedPrefCartList(List<CartModel> cartProductList);
  Future<ResponseModel> updateOrder(PlaceOrderModel placeOrderModel);
}