import 'package:get/get_connect/connect.dart';
import 'package:mnjood_vendor/features/business/domain/models/business_plan_body.dart';
import 'package:mnjood_vendor/interface/repository_interface.dart';

abstract class BusinessRepositoryInterface<T> implements RepositoryInterface<T> {
  Future<Response> setUpBusinessPlan(BusinessPlanBody businessPlanBody);
}