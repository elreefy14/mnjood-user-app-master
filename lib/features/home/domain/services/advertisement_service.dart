import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/home/domain/models/advertisement_model.dart';
import 'package:mnjood/features/home/domain/repositories/advertisement_repository_interface.dart';
import 'package:mnjood/features/home/domain/services/advertisement_service_interface.dart';

class AdvertisementService implements AdvertisementServiceInterface{
  final AdvertisementRepositoryInterface advertisementRepositoryInterface;
  AdvertisementService({required this.advertisementRepositoryInterface});

  @override
  Future<List<AdvertisementModel>?> getAdvertisementList({required DataSourceEnum source, String? businessType}) async {
    return await advertisementRepositoryInterface.getList(source: source, businessType: businessType);
  }

}