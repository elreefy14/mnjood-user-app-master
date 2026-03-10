import 'package:mnjood/common/widgets/enterprise_section_header_widget.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/product/controllers/campaign_controller.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/features/home/widgets/pharmacy_item_card_widget.dart';
import 'package:mnjood/features/home/widgets/supermarket_item_card_widget.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class TodayTrendsViewWidget extends StatefulWidget {
  final String? businessType;
  const TodayTrendsViewWidget({super.key, this.businessType});

  @override
  State<TodayTrendsViewWidget> createState() => _TodayTrendsViewWidgetState();
}

class _TodayTrendsViewWidgetState extends State<TodayTrendsViewWidget> {


  final ScrollController _scrollController = ScrollController();
  double _progressValue = 0.2;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
    // Load campaign data for the specific business type
    if (widget.businessType != null) {
      Get.find<CampaignController>().getItemCampaignList(false, businessType: widget.businessType);
    }
  }

  void _updateProgress() {
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double progress = currentScroll / maxScrollExtent;
    setState(() {
      _progressValue = progress;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
    super.dispose();
  }


  String _getTitle() {
    switch (widget.businessType?.toLowerCase()) {
      case 'pharmacy':
        return 'special_offers'.tr;
      case 'coffee_shop':
        return 'trending_drinks'.tr;
      default:
        return 'today_trends'.tr;
    }
  }

  String _getSubtitle() {
    switch (widget.businessType?.toLowerCase()) {
      case 'pharmacy':
        return 'check_out_our_special_offers'.tr;
      case 'coffee_shop':
        return 'popular_drinks_you_might_like'.tr;
      default:
        return 'here_what_you_might_like_to_taste'.tr;
    }
  }

  IconData _getIcon() {
    switch (widget.businessType?.toLowerCase()) {
      case 'pharmacy':
        return HeroiconsSolid.heart;
      case 'coffee_shop':
        return HeroiconsSolid.fire;
      default:
        return HeroiconsSolid.chartBar;
    }
  }

  Widget _buildProductCard(Product product, double cardWidth) {
    switch (widget.businessType?.toLowerCase()) {
      case 'pharmacy':
        return PharmacyItemCardWidget(
          product: product,
          width: cardWidth,
          isCampaignItem: true,
        );
      case 'supermarket':
        return SupermarketItemCardWidget(
          product: product,
          width: cardWidth,
          isCampaignItem: true,
        );
      default:
        return ItemCardWidget(
          width: cardWidth,
          product: product,
          isBestItem: false,
          isPopularNearbyItem: false,
          isCampaignItem: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CampaignController>(builder: (campaignController) {
      // Use businessType-specific list if provided, otherwise use default list
      final itemList = widget.businessType != null
          ? campaignController.getItemCampaignListByType(widget.businessType)
          : campaignController.itemCampaignList;

      return (itemList != null && itemList.isEmpty) ? const SizedBox() : Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
        ),
        child: Container(
          height: ResponsiveHelper.isDesktop(context) ? 435 : 430,
          width: Dimensions.webMaxWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Enterprise section header
            Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.paddingSizeDefault,
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
              ),
              child: ResponsiveHelper.isDesktop(context)
                ? Text(_getTitle(), style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EnterpriseSectionHeaderWidget(
                        icon: _getIcon(),
                        title: _getTitle(),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 44),
                        child: Text(
                          _getSubtitle(),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            itemList != null ? Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: itemList.length,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final cardWidth = ResponsiveHelper.isDesktop(context) ? 180.0 : 160.0;
                    final isLast = index == itemList.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 16 : 8,
                        right: isLast ? 16 : 8,
                      ),
                      child: SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 290 : 275,
                        child: _buildProductCard(itemList[index], cardWidth),
                      ),
                    );
                  },
                ),
            ) :  const ItemCardShimmer(isPopularNearbyItem: false),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Center(
                child: SizedBox(
                  height: 15, width: context.width*0.3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    width: 30, height: 5,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        value: _progressValue,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ]),
        ),
      );
    });
  }
}
