import 'package:mnjood/features/search/controllers/search_controller.dart' as search;
import 'package:mnjood/features/search/widgets/item_view_widget.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultWidget extends StatefulWidget {
  final String searchText;
  final String? businessType;
  const SearchResultWidget({super.key, required this.searchText, this.businessType});

  @override
  SearchResultWidgetState createState() => SearchResultWidgetState();
}

class SearchResultWidgetState extends State<SearchResultWidget> with TickerProviderStateMixin {
  TabController? _tabController;

  ScrollController scrollController = ScrollController();

  /// Get dynamic product tab label based on business type
  String _getProductTabLabel() {
    switch (widget.businessType?.toLowerCase()) {
      case 'supermarket':
        return 'products'.tr;
      case 'pharmacy':
        return 'medicines'.tr;
      default:
        return 'food'.tr;
    }
  }

  /// Get dynamic vendor tab label based on business type
  String _getVendorTabLabel() {
    switch (widget.businessType?.toLowerCase()) {
      case 'supermarket':
        return 'supermarkets'.tr;
      case 'pharmacy':
        return 'pharmacies'.tr;
      default:
        return 'restaurants'.tr;
    }
  }

  @override
  void initState() {
    super.initState();

    search.SearchController searchController = Get.find<search.SearchController>();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && searchController.totalSize != null && searchController.pageOffset != null) {
        int totalPage = (searchController.totalSize! / 10).ceil();
        if(searchController.pageOffset! < totalPage){
          // Pass businessType for pagination to maintain context
          searchController.searchData1(searchController.searchText, searchController.pageOffset!+1, businessType: widget.businessType);
          searchController.pageOffset = searchController.pageOffset!+1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      GetBuilder<search.SearchController>(builder: (searchController) {
        bool isNull = true;
        int length = 0;
        if(searchController.isRestaurant) {
          isNull = searchController.searchRestList == null;
          if(!isNull) {
            length = searchController.searchRestList!.length;
          }
        }else {
          isNull = searchController.searchProductList == null;
          if(!isNull) {
            length = searchController.totalSize??0;
          }
        }
        return isNull ? const SizedBox() : Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [
            Text(
              length.toString(),
              style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              'results_found'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Flexible(
              child: Text(
                widget.searchText,
                style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        )));
      }),

      Center(child: Container(
        width: Dimensions.webMaxWidth,
        color: Theme.of(context).cardColor,
        child: Align(
          alignment: ResponsiveHelper.isDesktop(context) ? Alignment.centerLeft : Alignment.center,
          child: Container(
            width: ResponsiveHelper.isDesktop(context) ? 250 : Dimensions.webMaxWidth,
            color: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).disabledColor,
              unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              onTap: (int index) {
                Get.find<search.SearchController>().setRestaurant(index == 1);
                // Pass businessType when switching tabs to maintain context
                Get.find<search.SearchController>().searchData1(widget.searchText, 1, businessType: widget.businessType);
              },

              tabs: [
                Tab(text: _getProductTabLabel()),
                Tab(text: _getVendorTabLabel()),
              ],
            ),
          ),
        ),
      )),

      Expanded(child: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ItemViewWidget(isRestaurant: false, scrollController: scrollController, businessType: widget.businessType),
          ItemViewWidget(isRestaurant: true, scrollController: scrollController, businessType: widget.businessType),
        ],
      )),

    ]);
  }
}
