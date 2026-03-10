import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/home/domain/models/advertisement_model.dart';
import 'package:mnjood/interface/repository_interface.dart';

abstract class AdvertisementRepositoryInterface extends RepositoryInterface{
  @override
  Future<List<AdvertisementModel>?> getList({int? offset, DataSourceEnum? source, String? businessType});
}