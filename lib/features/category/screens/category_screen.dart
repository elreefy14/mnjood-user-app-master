import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/no_data_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class CategoryScreen extends StatefulWidget {
  final String? businessType;
  const CategoryScreen({super.key, this.businessType});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _businessType;

  @override
  void initState() {
    super.initState();

    // Get businessType from widget OR from arguments, default to 'restaurant'
    _businessType = widget.businessType;
    if (_businessType == null && Get.arguments != null) {
      _businessType = Get.arguments['businessType'];
    }
    _businessType ??= 'restaurant';

    Get.find<HomeController>().getBusinessTypeCategories(_businessType!, fromRecall: true);
  }

  @override
  Widget build(BuildContext context) {
    // Helper to get app bar title based on business type
    String _getAppBarTitle() {
      final type = _businessType!.toLowerCase();
      if (type == 'restaurant' || type == 'food') return 'restaurant_categories'.tr;
      if (type == 'pharmacy') return 'pharmacy_categories'.tr;
      if (type == 'coffee_shop' || type == 'coffee shop' || type == 'coffeeshop') return 'coffee_categories'.tr;
      return 'categories'.tr;
    }

    return Scaffold(
      appBar: CustomAppBarWidget(title: _getAppBarTitle()),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: _buildBusinessTypeCategories(),
    );
  }

  Widget _buildBusinessTypeCategories() {
    bool isArabic = Get.find<LocalizationController>().isLtr == false;

    return GetBuilder<HomeController>(builder: (homeController) {
      final categories = homeController.getCategoriesForBusinessType(_businessType!);

      if (categories == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (categories.isEmpty) {
        return NoDataScreen(title: 'no_category_found'.tr);
      }

      return SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          child: FooterViewWidget(
            child: Column(children: [
              // Search bar for mobile
              ResponsiveHelper.isDesktop(context) ? const SizedBox() : Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault,
                  top: Dimensions.paddingSizeDefault,
                ),
                child: SizedBox(
                  height: 47,
                  child: SearchBar(
                    controller: _searchController,
                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).cardColor),
                    elevation: const WidgetStatePropertyAll(0),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
                    ),
                    onChanged: (value) {
                      homeController.update();
                    },
                    hintText: 'search_by_category'.tr,
                    hintStyle: WidgetStatePropertyAll(
                      robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    ),
                    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
                    leading: Icon(
                      HeroiconsOutline.magnifyingGlass,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                    ),
                    trailing: _searchController.text.isEmpty
                        ? [const SizedBox()]
                        : [
                            InkWell(
                              child: Icon(
                                HeroiconsOutline.xMark,
                                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                              ),
                              onTap: () {
                                _searchController.clear();
                                homeController.update();
                              },
                            )
                          ],
                  ),
                ),
              ),

              // Categories grid
              Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Builder(builder: (context) {
                    // Filter categories based on search
                    final filteredCategories = _searchController.text.isEmpty
                        ? categories
                        : categories.where((cat) {
                            final name = (cat.name ?? '').toLowerCase();
                            final nameAr = (cat.nameAr ?? '').toLowerCase();
                            final search = _searchController.text.toLowerCase();
                            return name.contains(search) || nameAr.contains(search);
                          }).toList();

                    if (filteredCategories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: NoDataScreen(title: 'no_category_found'.tr),
                      );
                    }

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.isDesktop(context)
                            ? 7
                            : ResponsiveHelper.isTab(context)
                                ? 4
                                : 3,
                        childAspectRatio: (1 / 1),
                        mainAxisSpacing: Dimensions.paddingSizeSmall,
                        crossAxisSpacing: Dimensions.paddingSizeSmall,
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        String displayName = isArabic && category.nameAr != null && category.nameAr!.isNotEmpty
                            ? category.nameAr!
                            : category.name ?? '';

                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                                blurRadius: 5,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: CustomInkWellWidget(
                            onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                              category.id!,
                              category.name!,
                              businessType: _businessType,
                            )),
                            radius: Dimensions.radiusDefault,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: CustomImageWidget(
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    image: '${category.imageFullUrl}',
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  displayName,
                                  textAlign: TextAlign.center,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ]),
          ),
        ),
      );
    });
  }
}
