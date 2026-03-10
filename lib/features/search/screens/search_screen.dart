import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/common/widgets/search_field_widget.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/search/controllers/search_controller.dart' as search;
import 'package:mnjood/features/search/widgets/filter_widget.dart';
import 'package:mnjood/features/search/widgets/search_result_widget.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/helper/voice_permission_handler.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/bottom_cart_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class SearchScreen extends StatefulWidget {
  final String? businessType;

  const SearchScreen({super.key, this.businessType});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final ScrollController scrollController = ScrollController();
  final GlobalKey _searchBarKey = GlobalKey();

  late bool _isLoggedIn;
  final TextEditingController _searchTextEditingController = TextEditingController();

  List<String> _foodsAndRestaurants = <String>[];
  bool _showSuggestion = false;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    Get.find<search.SearchController>().setSearchMode(true, canUpdate: false);

    // Set business type for category-specific search
    if (widget.businessType != null) {
      Get.find<search.SearchController>().setBusinessType(widget.businessType!);
    } else {
      Get.find<search.SearchController>().setBusinessType('all');
    }

    if(_isLoggedIn) {
      Get.find<search.SearchController>().getSuggestedFoods();
    }
    Get.find<search.SearchController>().getHistoryList();
  }

  Future<void> _searchSuggestions(String query) async {
    _foodsAndRestaurants = [];
    if (query == '') {
      _showSuggestion = false;
      _foodsAndRestaurants = [];
    } else {
      _showSuggestion = true;
      _foodsAndRestaurants = await Get.find<search.SearchController>().getSearchSuggestions(query);
    }
    setState(() {});
  }

  void _actionOnBackButton() {
    if(!Get.find<search.SearchController>().isSearchMode) {
      Get.find<search.SearchController>().setSearchMode(true);
      _searchTextEditingController.text = '';
      _showSuggestion = false;
    } else if(_searchTextEditingController.text.isNotEmpty) {
      _searchTextEditingController.text = '';
      _showSuggestion = false;
      setState(() {});
    } else {
      Future.delayed(const Duration(milliseconds: 10), () => Get.offAllNamed(RouteHelper.getInitialRoute()));
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _actionOnBackButton();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: isDesktop ? const WebMenuBar() : null,
        endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
        body: SafeArea(child: GetBuilder<search.SearchController>(builder: (searchController) {
          return Column(children: [

            Container(
              height: isDesktop ? 100 : 80,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 10, spreadRadius: 2, offset: Offset(0, 5))],
              ),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                SizedBox(width: Dimensions.webMaxWidth, child: Row(children: [
                  SizedBox(width: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),

                  !isDesktop ? IconButton(
                    onPressed: ()=> _actionOnBackButton(),
                    icon: const Icon(HeroiconsOutline.chevronLeft),
                  ) : const SizedBox(),

                  Expanded(child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(children: [

                      IconButton(
                        key: _searchBarKey,
                        onPressed: (){
                          _actionSearch(context, searchController, false);
                        },
                        icon: Icon(!searchController.isSearchMode ? HeroiconsOutline.funnel : HeroiconsOutline.magnifyingGlass, size: 28, color: Theme.of(context).disabledColor),
                      ),

                      Expanded(child: SearchFieldWidget(
                        controller: _searchTextEditingController,
                        hint: 'search_food_or_restaurant'.tr,
                        onChanged: (value) {
                          _searchSuggestions(value);
                        },
                        onSubmit: (value) {
                          _actionSearch(context, searchController, true);
                          if(!searchController.isSearchMode && _searchTextEditingController.text.isEmpty) {
                            searchController.setSearchMode(true);
                          }
                        },

                      )),

                      IconButton(
                        onPressed: () async {
                          await VoicePermissionHandler.openVoiceSearch(
                            context: context,
                            searchTextEditingController: _searchTextEditingController,
                            isDesktop: isDesktop,
                          );
                        },
                        icon: Icon(HeroiconsOutline.microphone, size: 28, color: Theme.of(context).disabledColor),
                      ),

                    ]),
                  )),
                  SizedBox(width: isDesktop ? 0 : 30),
                ])),
              ])),
            ),

            Expanded(child: searchController.isSearchMode ? _showSuggestion ? showSuggestions(
              context, searchController, _foodsAndRestaurants,
            ) : SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: FooterViewWidget(
                child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  searchController.historyList.isNotEmpty ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('recent_search'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

                    InkWell(
                      onTap: () => searchController.clearSearchAddress(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 4),
                        child: Text('clear_all'.tr, style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error,
                        )),
                      ),
                    ),
                  ]) : const SizedBox(),

                  SizedBox(height: searchController.historyList.isNotEmpty ? Dimensions.paddingSizeExtraSmall : 0),

                  SizedBox(
                    child: ListView.builder(
                      itemCount: searchController.historyList.length > 10 ? 10 : searchController.historyList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            _searchTextEditingController.text = searchController.historyList[index];
                            if (widget.businessType == null) {
                              Get.toNamed(RouteHelper.getUniversalSearchResultsRoute(searchController.historyList[index]));
                            } else {
                              searchController.searchData1(searchController.historyList[index], 1, businessType: widget.businessType);
                            }
                          },
                          child: Row(children: [

                            Icon(HeroiconsOutline.magnifyingGlass, size: 18, color: Theme.of(context).disabledColor),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                child: Text(
                                  searchController.historyList[index],
                                  style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => searchController.removeHistory(index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                child: Icon(HeroiconsOutline.xMark, color: Theme.of(context).disabledColor, size: 20),
                              ),
                            )
                          ]),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: searchController.historyList.isNotEmpty && _isLoggedIn ? Dimensions.paddingSizeLarge : 0),

                  _isLoggedIn ? (searchController.suggestedFoodList == null || (searchController.suggestedFoodList != null && searchController.suggestedFoodList!.isNotEmpty)) ? Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: Text(
                      'recommended'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                  ) : const SizedBox() : const SizedBox(),

                  _isLoggedIn ? searchController.suggestedFoodList != null ? searchController.suggestedFoodList!.isNotEmpty ?  Wrap(
                    children: searchController.suggestedFoodList!.map((product) {
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () {
                            _searchTextEditingController.text = product.name!;
                            if (widget.businessType == null) {
                              Get.toNamed(RouteHelper.getUniversalSearchResultsRoute(product.name!));
                            } else {
                              searchController.searchData1(product.name!, 1, businessType: widget.businessType);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.6)),
                            ),
                            child: Text(
                              product.name!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ) : const SizedBox() : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      children: [0,1,2,3,4,5].map((n) {
                        return Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                          child: Shimmer(child: Container(height: 30, width: n%3==0 ? 100 : 150, color: Theme.of(context).shadowColor)),
                        );
                      }).toList(),
                    ),
                  ) : const SizedBox(),

                ])),
              ),
            ) : SearchResultWidget(searchText: _searchTextEditingController.text.trim(), businessType: widget.businessType)),

          ]);
        })),
        bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty && !isDesktop ? const BottomCartWidget() : const SizedBox();
        }),
      ),
    );
  }

  Widget showSuggestions(BuildContext context, search.SearchController searchController, List<String> foodsAndRestaurants) {
    return SingleChildScrollView(
      child: FooterViewWidget(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: foodsAndRestaurants.isNotEmpty ? ListView.builder(
            itemCount: foodsAndRestaurants.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              String suggestion = foodsAndRestaurants[index];

              // Parse suggestion to extract name and subtitle
              // Format from controller:
              // - Food: "Product Name (Vendor Name - Type)" e.g. "Pizza (Al-Reef - restaurant)"
              // - Vendor: "Vendor Name (Type)" e.g. "Al-Reef (restaurant)"
              String title = suggestion;
              String? subtitle;
              bool isVendor = false;

              // Check for vendor pattern: "Vendor Name (restaurant|supermarket|pharmacy)"
              RegExp vendorPattern = RegExp(r'^(.+?) \((restaurant|supermarket|pharmacy)\)$', caseSensitive: false);
              // Check for food pattern: "Product Name (Vendor Name - Type)"
              RegExp foodPattern = RegExp(r'^(.+?) \((.+?) - (restaurant|supermarket|pharmacy)\)$', caseSensitive: false);

              if (vendorPattern.hasMatch(suggestion)) {
                var match = vendorPattern.firstMatch(suggestion)!;
                title = match.group(1)!;
                subtitle = match.group(2)!;
                isVendor = true;
              } else if (foodPattern.hasMatch(suggestion)) {
                var match = foodPattern.firstMatch(suggestion)!;
                title = match.group(1)!;
                String vendorName = match.group(2)!;
                String vendorType = match.group(3)!;
                subtitle = '$vendorName ($vendorType)';
              }

              return ListTile(
                title: Text(title, style: robotoRegular),
                subtitle: subtitle != null
                    ? Text(
                        subtitle,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      )
                    : null,
                leading: Icon(
                  isVendor ? HeroiconsOutline.buildingStorefront : HeroiconsOutline.magnifyingGlass,
                  color: Theme.of(context).disabledColor,
                ),
                trailing: Icon(HeroiconsOutline.arrowUpLeft, color: Theme.of(context).disabledColor),
                onTap: () async {
                  // For universal search, navigate to results screen
                  // For category-specific search, perform the search
                  if (widget.businessType == null) {
                    // Navigate to universal search with the title (name)
                    Get.toNamed(RouteHelper.getUniversalSearchResultsRoute(title));
                  } else {
                    _searchTextEditingController.text = title;
                    searchController.searchData1(title, 1, businessType: widget.businessType);
                  }
                },
              );
            },
          ) : Padding(
            padding: EdgeInsets.only(top: context.height * 0.2),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CustomAssetImageWidget(Images.emptyRestaurant),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('no_suggestions_found'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
            ]),
          ),
        ),
      ),
    );
  }

  void _actionSearch(BuildContext context, search.SearchController searchController, bool isSubmit) {
    if(searchController.isSearchMode || isSubmit) {
      if(_searchTextEditingController.text.trim().isNotEmpty) {
        String query = _searchTextEditingController.text.trim();

        // If no business type filter (universal search from homepage), navigate to UniversalSearchResultsScreen
        if (widget.businessType == null) {
          Get.toNamed(RouteHelper.getUniversalSearchResultsRoute(query));
        } else {
          // Category-specific search - use the standard search
          searchController.searchData1(query, 1, businessType: widget.businessType);
        }
      }else {
        showCustomSnackBar('search_food_or_restaurant'.tr);
      }
    } else {
      double? maxValue = searchController.upperValue > 0 ? searchController.upperValue : 1000;
      double? minValue = searchController.lowerValue;
      // Pass businessType to FilterWidget to maintain context
      ResponsiveHelper.isMobile(context) ? Get.bottomSheet(FilterWidget(maxValue: maxValue, minValue: minValue, isRestaurant: searchController.isRestaurant, businessType: widget.businessType), isScrollControlled: true)
      : _showSearchDialog(maxValue, minValue, searchController.isRestaurant, widget.businessType);
    }
  }


  Future<void> _showSearchDialog(double? maxValue, double? minValue, bool isRestaurant, String? businessType) async {
    RenderBox renderBox = _searchBarKey.currentContext!.findRenderObject() as RenderBox;
    final searchBarPosition = renderBox.localToGlobal(Offset.zero);

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(children: [
        Positioned(
          top: searchBarPosition.dy + 40,
          left: searchBarPosition.dx - 400,
          width: renderBox.size.width + 400,
          height: renderBox.size.height + MediaQuery.of(context).size.height * 0.6,
          child: Material(
            color: Theme.of(context).cardColor,
            elevation: 0,
            borderRadius: BorderRadius.circular(30),
            child: FilterWidget(maxValue: maxValue, minValue: minValue, isRestaurant: isRestaurant, businessType: businessType),
          ),
        ),

      ]),
    );

  }

}
