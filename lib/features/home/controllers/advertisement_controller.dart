import 'package:get/get.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/home/domain/models/advertisement_model.dart';
import 'package:mnjood/features/home/domain/services/advertisement_service_interface.dart';

class AdvertisementController extends GetxController implements GetxService {
  final AdvertisementServiceInterface advertisementServiceInterface;
  AdvertisementController({required this.advertisementServiceInterface});

  List<AdvertisementModel>? _advertisementList;
  List<AdvertisementModel>? get advertisementList => _advertisementList;

  // Cache for business type specific advertisement lists
  final Map<String, List<AdvertisementModel>> _advertisementListByType = {};
  List<AdvertisementModel>? getAdvertisementListByType(String? businessType) =>
      _advertisementListByType[businessType ?? 'all'];

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Duration autoPlayDuration = const Duration(seconds: 7);

  bool autoPlay = true;

  Future<void> getAdvertisementList({DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false, String? businessType}) async {
    String cacheKey = businessType ?? 'all';
    bool hasData = businessType != null ? _advertisementListByType.containsKey(cacheKey) : _advertisementList != null;

    if(!hasData || fromRecall) {
      if(!fromRecall) {
        if (businessType != null) {
          _advertisementListByType.remove(cacheKey);
        } else {
          _advertisementList = null;
        }
      }

      List<AdvertisementModel>? advertisementList;
      if(dataSource == DataSourceEnum.local) {
        advertisementList = await advertisementServiceInterface.getAdvertisementList(source: DataSourceEnum.local, businessType: businessType);
        _prepareAdvertisement(advertisementList, businessType: businessType);
        getAdvertisementList(dataSource: DataSourceEnum.client, fromRecall: true, businessType: businessType);
      } else {
        advertisementList = await advertisementServiceInterface.getAdvertisementList(source: DataSourceEnum.client, businessType: businessType);
        _prepareAdvertisement(advertisementList, businessType: businessType);
      }
    }
  }

  void _prepareAdvertisement(List<AdvertisementModel>? advertisementList, {String? businessType}) {
    // Always store the list (empty if null) so widgets can properly hide when no data
    if (businessType != null) {
      _advertisementListByType[businessType] = advertisementList ?? [];
    } else {
      _advertisementList = advertisementList ?? [];
    }
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  void updateAutoPlayStatus({bool shouldUpdate = false, bool status = false}){
    autoPlay = status;
    if(shouldUpdate){
      update();
    }
  }

}