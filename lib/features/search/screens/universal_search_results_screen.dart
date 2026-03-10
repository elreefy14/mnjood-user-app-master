import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/common/widgets/custom_loader_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/features/search/controllers/search_controller.dart' as search;
import 'package:mnjood/features/search/widgets/universal_search_tab_content_widget.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';

class UniversalSearchResultsScreen extends StatefulWidget {
  final String query;
  final String? initialTab;

  const UniversalSearchResultsScreen({
    super.key,
    required this.query,
    this.initialTab,
  });

  @override
  State<UniversalSearchResultsScreen> createState() => _UniversalSearchResultsScreenState();
}

class _UniversalSearchResultsScreenState extends State<UniversalSearchResultsScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  static const List<String> _allBusinessTypes = ['restaurant', 'coffee_shop', 'supermarket', 'pharmacy'];
  static const Map<String, String> _labelMap = {
    'restaurant': 'restaurants',
    'coffee_shop': 'coffee_shops',
    'supermarket': 'supermarkets',
    'pharmacy': 'pharmacies',
  };

  List<String> _activeTypes = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<search.SearchController>().universalSearch(widget.query);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _rebuildTabs(search.SearchController controller) {
    final filtered = _allBusinessTypes.where((t) => controller.hasResultsForType(t)).toList();

    if (_listEquals(filtered, _activeTypes) && _tabController != null) return;

    _activeTypes = filtered;
    _tabController?.dispose();

    if (_activeTypes.isEmpty) {
      _tabController = null;
      return;
    }

    int initialIndex = 0;
    if (widget.initialTab != null) {
      int idx = _activeTypes.indexOf(widget.initialTab!.toLowerCase());
      if (idx >= 0) initialIndex = idx;
    }

    _tabController = TabController(
      length: _activeTypes.length,
      vsync: this,
      initialIndex: initialIndex.clamp(0, _activeTypes.length - 1),
    );
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: '"${widget.query}"',
        isBackButtonExist: true,
      ),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<search.SearchController>(
        builder: (searchController) {
          if (searchController.isUniversalSearchLoading) {
            return const Center(child: CustomLoaderWidget());
          }

          _rebuildTabs(searchController);

          if (_activeTypes.isEmpty || _tabController == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomAssetImageWidget(Images.emptyRestaurant),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text('no_food_available'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                color: Theme.of(context).cardColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 3,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).disabledColor,
                  labelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: _activeTypes.map((type) {
                    return Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_labelMap[type]!.tr),
                          _buildResultCountBadge(searchController, type),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _activeTypes.map((businessType) {
                    return UniversalSearchTabContentWidget(
                      businessType: businessType,
                      searchController: searchController,
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultCountBadge(search.SearchController controller, String businessType) {
    int count = controller.getResultsCountForType(businessType);
    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
