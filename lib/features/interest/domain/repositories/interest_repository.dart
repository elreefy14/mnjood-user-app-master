import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/interest/domain/repositories/interest_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class InterestRepository implements InterestRepositoryInterface{
  final ApiClient apiClient;
  InterestRepository({required this.apiClient});

  @override
  Future<bool> saveUserInterests(List<int?> interests) async {
    Response response = await apiClient.putData(AppConstants.interestUri, {"interest": interests});
    return response.statusCode == 200;
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
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}