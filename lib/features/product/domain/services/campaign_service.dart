import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/product/domain/models/basic_campaign_model.dart';
import 'package:mnjood/features/product/domain/repositories/campaign_repository_interface.dart';
import 'package:mnjood/features/product/domain/services/campaign_service_interface.dart';

class CampaignService implements CampaignServiceInterface {
  final CampaignRepositoryInterface campaignRepositoryInterface;

  CampaignService({required this.campaignRepositoryInterface});

  @override
  Future<List<BasicCampaignModel>?> getBasicCampaignList() async {
    return await campaignRepositoryInterface.getList(basicCampaign: true);
  }

  @override
  Future<List<Product>?> getItemCampaignList({DataSourceEnum? source, String? businessType}) async {
    return await campaignRepositoryInterface.getList(source: source, businessType: businessType);
  }

  @override
  Future<BasicCampaignModel?> getCampaignDetails(String campaignID) async {
    return await campaignRepositoryInterface.get(campaignID);
  }

}