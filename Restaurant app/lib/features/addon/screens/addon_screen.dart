import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/common/widgets/empty_state_widget.dart';
import 'package:mnjood_vendor/common/widgets/filter_chip_row.dart';
import 'package:mnjood_vendor/features/addon/controllers/addon_controller.dart';
import 'package:mnjood_vendor/features/addon/widgets/addon_delete_bottom_sheet.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:mnjood_vendor/features/splash/controllers/splash_controller.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/app_colors.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class AddonScreen extends StatefulWidget {
  const AddonScreen({super.key});

  @override
  State<AddonScreen> createState() => _AddonScreenState();
}

class _AddonScreenState extends State<AddonScreen> {
  bool _isGridView = false;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    Get.find<AddonController>().getAddonList();
    Get.find<AddonController>().getAddonCategoryList();

    if (Get.find<SplashController>().configModel!.systemTaxType == 'product_wise') {
      Get.find<RestaurantController>().getVatTaxList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'addons'.tr,
        menuWidget: _buildViewToggle(),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      body: GetBuilder<AddonController>(builder: (addonController) {
        if (addonController.addonList == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (addonController.addonList!.isEmpty) {
          return EmptyStateWidget(
            title: 'no_addon_found'.tr,
            subtitle: 'add_addons_to_enhance_items'.tr,
            icon: HeroiconsOutline.puzzlePiece,
            action: _buildAddButton(context),
          );
        }

        final filteredAddons = _getFilteredAddons(addonController);

        return Column(
          children: [
            // Category filter
            if (addonController.addonCategoryList != null &&
                addonController.addonCategoryList!.isNotEmpty)
              _buildCategoryFilter(addonController),

            // Summary stats
            _buildSummaryStats(addonController),

            // Addons list/grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await addonController.getAddonList();
                  await addonController.getAddonCategoryList();
                },
                child: filteredAddons.isEmpty
                    ? _buildEmptyFilterState()
                    : _isGridView
                        ? _buildGridView(filteredAddons, addonController)
                        : _buildListView(filteredAddons, addonController),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildViewToggle() {
    return IconButton(
      onPressed: () => setState(() => _isGridView = !_isGridView),
      icon: Icon(
        _isGridView ? HeroiconsOutline.listBullet : HeroiconsOutline.squares2x2,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddAddon(),
      backgroundColor: Theme.of(context).primaryColor,
      icon: const Icon(HeroiconsOutline.plus, color: Colors.white),
      label: Text('add'.tr, style: robotoMedium.copyWith(color: Colors.white)),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _navigateToAddAddon(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeSmall,
        ),
      ),
      icon: const Icon(HeroiconsOutline.plus),
      label: Text('add_addon'.tr),
    );
  }

  void _navigateToAddAddon() {
    if (Get.find<ProfileController>().profileModel!.restaurants![0].foodSection!) {
      Get.toNamed(RouteHelper.getAddAddonRoute(addon: null));
    } else {
      showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
    }
  }

  Widget _buildCategoryFilter(AddonController controller) {
    final categories = <FilterChipItem>[
      FilterChipItem(
        id: 'all',
        label: 'all'.tr,
        count: controller.addonList!.length,
      ),
    ];

    // Group addons by category to get counts
    final categoryMap = <int?, int>{};
    for (final addon in controller.addonList!) {
      final catId = addon.addonCategoryId;
      categoryMap[catId] = (categoryMap[catId] ?? 0) + 1;
    }

    // Add category filters
    for (final cat in controller.addonCategoryList!) {
      categories.add(FilterChipItem(
        id: cat.id.toString(),
        label: cat.name ?? 'unknown'.tr,
        count: categoryMap[cat.id] ?? 0,
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: FilterChipRow(
        items: categories,
        selectedId: _selectedCategory,
        onSelected: (id) => setState(() => _selectedCategory = id),
      ),
    );
  }

  Widget _buildSummaryStats(AddonController controller) {
    final totalAddons = controller.addonList!.length;
    final freeAddons = controller.addonList!.where((a) => a.price == 0).length;
    final paidAddons = totalAddons - freeAddons;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(Get.isDarkMode ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('total'.tr, totalAddons.toString(), HeroiconsOutline.puzzlePiece),
          _buildStatDivider(),
          _buildStatItem('free'.tr, freeAddons.toString(), HeroiconsOutline.gift),
          _buildStatDivider(),
          _buildStatItem('paid'.tr, paidAddons.toString(), HeroiconsOutline.banknotes),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }

  List<AddOns> _getFilteredAddons(AddonController controller) {
    if (_selectedCategory == 'all') return controller.addonList!;

    final categoryId = int.tryParse(_selectedCategory);
    return controller.addonList!
        .where((addon) => addon.addonCategoryId == categoryId)
        .toList();
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(HeroiconsOutline.funnel, size: 48, color: Colors.grey[400]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            'no_addons_in_category'.tr,
            style: robotoMedium.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          TextButton(
            onPressed: () => setState(() => _selectedCategory = 'all'),
            child: Text('show_all'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<AddOns> addons, AddonController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemCount: addons.length,
      itemBuilder: (context, index) {
        return _buildAddonListItem(addons[index], controller);
      },
    );
  }

  Widget _buildGridView(List<AddOns> addons, AddonController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
      ),
      itemCount: addons.length,
      itemBuilder: (context, index) {
        return _buildAddonGridItem(addons[index], controller);
      },
    );
  }

  Widget _buildAddonListItem(AddOns addon, AddonController controller) {
    final bool isDark = Get.isDarkMode;
    final bool isFree = addon.price == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToEditAddon(addon),
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Icon(
                    HeroiconsOutline.puzzlePiece,
                    size: 22,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addon.name ?? '',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isFree
                                  ? AppColors.success.withOpacity(0.15)
                                  : Theme.of(context).primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isFree
                                  ? 'free'.tr
                                  : PriceConverter.convertPrice(addon.price),
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: isFree
                                    ? AppColors.success
                                    : Theme.of(context).primaryColor,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          if (addon.addonCategoryId != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _getCategoryName(addon.addonCategoryId, controller),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: HeroiconsOutline.pencilSquare,
                      color: AppColors.info,
                      onTap: () => _navigateToEditAddon(addon),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: HeroiconsOutline.trash,
                      color: AppColors.error,
                      onTap: () => _showDeleteConfirmation(addon.id!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddonGridItem(AddOns addon, AddonController controller) {
    final bool isDark = Get.isDarkMode;
    final bool isFree = addon.price == 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToEditAddon(addon),
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Icon(
                        HeroiconsOutline.puzzlePiece,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Name
                    Expanded(
                      child: Text(
                        addon.name ?? '',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isFree
                            ? AppColors.success.withOpacity(0.15)
                            : Theme.of(context).primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isFree
                            ? 'free'.tr
                            : PriceConverter.convertPrice(addon.price),
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: isFree
                              ? AppColors.success
                              : Theme.of(context).primaryColor,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions menu
              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    HeroiconsOutline.ellipsisVertical,
                    size: 18,
                    color: Colors.grey[500],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(HeroiconsOutline.pencilSquare, size: 18, color: AppColors.info),
                          const SizedBox(width: 8),
                          Text('edit'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(HeroiconsOutline.trash, size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('delete'.tr, style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEditAddon(addon);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(addon.id!);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  String _getCategoryName(int? categoryId, AddonController controller) {
    if (categoryId == null || controller.addonCategoryList == null) return '';
    final category = controller.addonCategoryList!
        .firstWhereOrNull((c) => c.id == categoryId);
    return category?.name ?? '';
  }

  void _navigateToEditAddon(AddOns addon) {
    if (Get.find<ProfileController>().profileModel!.restaurants![0].foodSection!) {
      Get.toNamed(RouteHelper.getAddAddonRoute(addon: addon));
    } else {
      showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
    }
  }

  void _showDeleteConfirmation(int addonId) {
    if (Get.find<ProfileController>().profileModel!.restaurants![0].foodSection!) {
      showCustomBottomSheet(
        child: AddonDeleteBottomSheet(addonId: addonId),
      );
    } else {
      showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
    }
  }
}
