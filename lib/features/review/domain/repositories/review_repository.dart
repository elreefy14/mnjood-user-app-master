import 'dart:convert';

import 'package:mnjood/api/local_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/response_model.dart';
import 'package:mnjood/common/models/review_model.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/product/domain/models/review_body_model.dart';
import 'package:mnjood/features/review/domain/repositories/review_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get.dart';

class ReviewRepository implements ReviewRepositoryInterface {
  final ApiClient apiClient;
  ReviewRepository({required this.apiClient});

  @override
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody, bool isProduct) async {
    if(isProduct) {
      return _submitReview(reviewBody);
    } else {
      return _submitDeliveryManReview(reviewBody);
    }
  }

  @override
  Future<List<Product>?> getList({int? offset, String? type, DataSourceEnum? source}) async {
    List<Product>? reviewedProductList;
    String cacheId = AppConstants.reviewedProductUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.reviewedProductUri}&type=$type');

        if(response.statusCode == 200){
          reviewedProductList = [];
          // V3 API: data is a List, wrap it for ProductModel
          var data = response.body['data'] ?? response.body;
          if(data is List) {
            reviewedProductList.addAll(ProductModel.fromJson({'products': data}).products ?? []);
          } else {
            reviewedProductList.addAll(ProductModel.fromJson(data).products ?? []);
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body['data'] ?? response.body), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          reviewedProductList = [];
          var data = jsonDecode(cacheResponseData);
          if(data is List) {
            reviewedProductList.addAll(ProductModel.fromJson({'products': data}).products ?? []);
          } else {
            reviewedProductList.addAll(ProductModel.fromJson(data).products ?? []);
          }
        }
    }
    return reviewedProductList;
  }

  Future<ResponseModel> _submitReview(ReviewBodyModel reviewBody) async {
    Response response = await apiClient.postData(AppConstants.reviewUri, reviewBody.toJson(), handleError: false);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ResponseModel(true, 'review_submitted_successfully'.tr);
    } else {
      // Extract error message from V3 API response
      String errorMessage = response.statusText ?? 'failed_to_submit_review'.tr;
      if (response.body != null) {
        if (response.body is Map) {
          errorMessage = response.body['message'] ?? response.body['error'] ?? errorMessage;
        }
      }
      return ResponseModel(false, errorMessage);
    }
  }

  Future<ResponseModel> _submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    Response response = await apiClient.postData(AppConstants.deliveryManReviewUri, reviewBody.toJson(), handleError: false);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ResponseModel(true, 'review_submitted_successfully'.tr);
    } else {
      // Extract error message from V3 API response
      String errorMessage = response.statusText ?? 'failed_to_submit_review'.tr;
      if (response.body != null) {
        if (response.body is Map) {
          errorMessage = response.body['message'] ?? response.body['error'] ?? errorMessage;
        }
      }
      return ResponseModel(false, errorMessage);
    }
  }

  @override
  Future<List<ReviewModel>?> getRestaurantReviewList(String? restaurantID) async {
    List<ReviewModel>? restaurantReviewList;
    Response response = await apiClient.getData('${AppConstants.restaurantReviewUri}?restaurant_id=$restaurantID');
    if (response.statusCode == 200) {
      restaurantReviewList = [];
      response.body.forEach((review) => restaurantReviewList!.add(ReviewModel.fromJson(review)));
    }
    return restaurantReviewList;
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
  
}