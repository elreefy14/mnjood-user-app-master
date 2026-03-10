import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/interface/repository_interface.dart';

abstract class ProductRepositoryInterface implements RepositoryInterface {

  @override
  Future<List<Product>?> getList({int? offset, String? type, DataSourceEnum? source});

  @override
  Future<Product?> get(String? id, {bool isCampaign = false, int? vendorId, String? businessType});

  /// Get pharmacy products from pharmacy-specific endpoints
  Future<List<Product>?> getPharmacyProducts({DataSourceEnum? source});
}