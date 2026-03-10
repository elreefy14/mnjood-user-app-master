import 'dart:convert';

import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/api/local_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/notification/domain/models/notification_model.dart';
import 'package:mnjood/features/notification/domain/repository/notification_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  NotificationRepository({required this.apiClient, required this.sharedPreferences});

  @override
  void saveSeenNotificationCount(int count) {
    sharedPreferences.setInt(AppConstants.notificationCount, count);
  }

  @override
  int? getSeenNotificationCount() {
    return sharedPreferences.getInt(AppConstants.notificationCount);
  }

  @override
  List<int> getNotificationIdList() {
    List<String>? list = [];
    if(sharedPreferences.containsKey(AppConstants.notificationIdList)) {
      list = sharedPreferences.getStringList(AppConstants.notificationIdList);
    }
    List<int> notificationIdList = [];
    for (var id in list!) {
      notificationIdList.add(jsonDecode(id));
    }
    return notificationIdList;
  }

  @override
  void addSeenNotificationIdList(List<int> notificationList) {
    List<String> list = [];
    for (int id in notificationList) {
      list.add(jsonEncode(id));
    }
    sharedPreferences.setStringList(AppConstants.notificationIdList, list);
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
  Future<List<NotificationModel>?> getList({int? offset, DataSourceEnum? source}) async {
    List<NotificationModel>? notificationList;
    String cacheId = AppConstants.notificationUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.notificationUri);
        if(response.statusCode == 200){
          notificationList = [];
          // Handle V3 API response wrapper
          var data = response.body;
          if (data is Map && data.containsKey('data')) {
            data = data['data'];
          }
          if (data is List) {
            data.forEach((notification) {
              notificationList!.add(NotificationModel.fromJson(notification));
            });
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(data), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          notificationList = [];
          var cachedData = jsonDecode(cacheResponseData);
          // Handle both direct array and V3 wrapped format from old cache
          if (cachedData is Map && cachedData.containsKey('data')) {
            cachedData = cachedData['data'];
          }
          if (cachedData is List) {
            cachedData.forEach((notification) {
              notificationList!.add(NotificationModel.fromJson(notification));
            });
          }
        }
    }
    return notificationList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}