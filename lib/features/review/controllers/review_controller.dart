import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/response_model.dart';
import 'package:mnjood/common/models/review_model.dart';
import 'package:mnjood/features/order/domain/models/order_details_model.dart';
import 'package:mnjood/features/product/domain/models/review_body_model.dart';
import 'package:mnjood/features/review/domain/services/review_service_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController implements GetxService {
  final ReviewServiceInterface reviewServiceInterface;

  ReviewController({required this.reviewServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<int> _ratingList = [];
  List<int> get ratingList => _ratingList;

  List<String> _reviewList = [];
  List<String> get reviewList => _reviewList;

  List<bool> _loadingList = [];
  List<bool> get loadingList => _loadingList;

  List<bool> _submitList = [];
  List<bool> get submitList => _submitList;

  int _deliveryManRating = 0;
  int get deliveryManRating => _deliveryManRating;

  String _reviewedType = 'all';
  String get reviewType => _reviewedType;

  List<Product>? _reviewedProductList;
  List<Product>? get reviewedProductList => _reviewedProductList;

  List<ReviewModel>? _restaurantReviewList;
  List<ReviewModel>? get restaurantReviewList => _restaurantReviewList;

  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _hasError = false;
    _errorMessage = '';
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    try {
      for (var orderDetails in orderDetailsList) {
        debugPrint('$orderDetails');
        _ratingList.add(0);
        _reviewList.add('');
        _loadingList.add(false);
        _submitList.add(false);
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      debugPrint('initRatingData error: $e');
    }
    update();
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    update();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    update();
  }

  Future<void> getReviewedProductList(bool reload, String type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    _reviewedType = type;
    if(reload && !fromRecall) {
      _reviewedProductList = null;
    }
    if(notify) {
      update();
    }
    List<Product>? reviewedProductList;
    if(_reviewedProductList == null || reload || fromRecall) {
      if(dataSource == DataSourceEnum.local) {
        reviewedProductList = await reviewServiceInterface.getReviewedProductList(type: type, source: DataSourceEnum.local);
        _prepareReviewedProductList(reviewedProductList);
        getReviewedProductList(false, type, false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        reviewedProductList = await reviewServiceInterface.getReviewedProductList(type: type, source: DataSourceEnum.client);
        _prepareReviewedProductList(reviewedProductList);
      }
    }
  }

  void _prepareReviewedProductList(List<Product>? reviewedProductList) {
    if(reviewedProductList != null) {
      _reviewedProductList = [];
      _reviewedProductList = reviewedProductList;
    }
    update();
  }

  Future<ResponseModel> submitReview(int index, ReviewBodyModel reviewBody) async {
    _loadingList[index] = true;
    update();

    try {
      ResponseModel responseModel = await reviewServiceInterface.submitProductReview(reviewBody);
      if(responseModel.isSuccess) {
        _submitList[index] = true;
      }
      _loadingList[index] = false;
      update();
      return responseModel;
    } catch (e) {
      _loadingList[index] = false;
      update();
      return ResponseModel(false, 'rating_error'.tr);
    }
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    _isLoading = true;
    update();

    try {
      ResponseModel responseModel = await reviewServiceInterface.submitDeliverymanReview(reviewBody);
      if(responseModel.isSuccess) {
        _deliveryManRating = 0;
      }
      _isLoading = false;
      update();
      return responseModel;
    } catch (e) {
      _isLoading = false;
      update();
      return ResponseModel(false, 'rating_error'.tr);
    }
  }

  Future<void> getRestaurantReviewList(String? restaurantID) async {
    try {
      _restaurantReviewList = await reviewServiceInterface.getRestaurantReviewList(restaurantID);
    } catch (e) {
      _hasError = true;
      _errorMessage = 'rating_error'.tr;
      debugPrint('getRestaurantReviewList error: $e');
    }
    update();
  }

}