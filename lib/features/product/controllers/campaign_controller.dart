import 'package:flutter/scheduler.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/helper/product_helper.dart';
import 'package:mnjood/features/product/domain/models/basic_campaign_model.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/product/domain/services/campaign_service_interface.dart';
import 'package:get/get.dart';

class CampaignController extends GetxController implements GetxService {
  final CampaignServiceInterface campaignServiceInterface;
  CampaignController({required this.campaignServiceInterface});

  List<BasicCampaignModel>? _basicCampaignList;
  List<BasicCampaignModel>? get basicCampaignList => _basicCampaignList;

  BasicCampaignModel? _campaign;
  BasicCampaignModel? get campaign => _campaign;

  List<Product>? _itemCampaignList;
  List<Product>? get itemCampaignList => _itemCampaignList;

  // Cache for business type specific campaign lists
  final Map<String, List<Product>> _itemCampaignListByType = {};
  List<Product>? getItemCampaignListByType(String? businessType) =>
      _itemCampaignListByType[businessType ?? 'all'];

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  /// Safely update the controller, avoiding setState during build errors
  void _safeUpdate() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // We're in the middle of a frame, schedule update for after the frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        update();
      });
    } else {
      update();
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  Future<void> getBasicCampaignList(bool reload) async {
    if(_basicCampaignList == null || reload) {
      _basicCampaignList = await campaignServiceInterface.getBasicCampaignList();
      _safeUpdate();
    }
  }

  Future<void> getBasicCampaignDetails(int? campaignID) async {
    // Don't set _campaign = null here - keep existing data while loading
    // to prevent shimmer/loading state from showing indefinitely
    _campaign = await campaignServiceInterface.getCampaignDetails(campaignID.toString());
    _safeUpdate();
  }

  /// Set campaign data directly from the widget without making an API call.
  /// This is used when campaign data is already passed from the banner API.
  void setCampaignFromWidget(BasicCampaignModel campaign) {
    _campaign = campaign;
    _safeUpdate();
  }

  Future<void> getItemCampaignList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false, String? businessType}) async {
    String cacheKey = businessType ?? 'all';
    bool hasData = businessType != null ? _itemCampaignListByType.containsKey(cacheKey) : _itemCampaignList != null;

    if(!hasData || reload || fromRecall) {
      if(!fromRecall) {
        if (businessType != null) {
          _itemCampaignListByType.remove(cacheKey);
        } else {
          _itemCampaignList = null;
        }
      }

      List<Product>? itemCampaignList;
      if(dataSource == DataSourceEnum.local) {
        itemCampaignList = await campaignServiceInterface.getItemCampaignList(source: DataSourceEnum.local, businessType: businessType);
        _prepareItemBasicCampaign(itemCampaignList, businessType: businessType);
        getItemCampaignList(false, dataSource: DataSourceEnum.client, fromRecall: true, businessType: businessType);
      } else {
        itemCampaignList = await campaignServiceInterface.getItemCampaignList(source: DataSourceEnum.client, businessType: businessType);
        _prepareItemBasicCampaign(itemCampaignList, businessType: businessType);
      }
    }
  }

  void _prepareItemBasicCampaign(List<Product>? itemCampaignList, {String? businessType}) {
    // Always store the list (empty if null) so widgets can properly hide when no data
    final filtered = (itemCampaignList ?? []).where((p) => ProductHelper.isInStock(p)).toList();
    if (businessType != null) {
      _itemCampaignListByType[businessType] = filtered;
    } else {
      _itemCampaignList = filtered;
    }
    _safeUpdate();
  }

}