import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/interface/repository_interface.dart';

abstract class AddressRepoInterface<T> implements RepositoryInterface<AddressModel> {
  @override
  Future<List<AddressModel>?> getList({int? offset, bool isLocal = false, DataSourceEnum? source});
}