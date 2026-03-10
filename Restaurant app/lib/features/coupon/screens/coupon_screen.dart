import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_loader_widget.dart';
import 'package:mnjood_vendor/common/widgets/empty_state_widget.dart';
import 'package:mnjood_vendor/common/widgets/filter_chip_row.dart';
import 'package:mnjood_vendor/features/coupon/controllers/coupon_controller.dart';
import 'package:mnjood_vendor/features/coupon/domain/models/coupon_body_model.dart';
import 'package:mnjood_vendor/features/coupon/screens/add_coupon_screen.dart';
import 'package:mnjood_vendor/features/coupon/widgets/coupon_card_dialogue_widget.dart';
import 'package:mnjood_vendor/features/coupon/widgets/coupon_delete_bottom_sheet.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/app_colors.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    Get.find<CouponController>().getCouponList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'coupon_list'.tr),
      floatingActionButton: _buildFloatingActionButton(context),
      body: GetBuilder<CouponController>(builder: (couponController) {
        if (couponController.couponList == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (couponController.couponList!.isEmpty) {
          return EmptyStateWidget.noCoupons(
            onAdd: () => Get.to(() => const AddCouponScreen()),
          );
        }

        final filteredCoupons = _getFilteredCoupons(couponController.couponList!);

        return Column(
          children: [
            // Filter tabs
            _buildFilterTabs(couponController.couponList!),

            // Coupons list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await couponController.getCouponList();
                },
                child: filteredCoupons.isEmpty
                    ? _buildEmptyFilterState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        itemCount: filteredCoupons.length,
                        itemBuilder: (context, index) {
                          return _buildCouponCard(
                            context,
                            filteredCoupons[index],
                            couponController,
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: FloatingActionButton(
        onPressed: () => Get.to(() => const AddCouponScreen()),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(HeroiconsOutline.plus, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildFilterTabs(List<CouponBodyModel> allCoupons) {
    final activeCount = allCoupons.where((c) => _getCouponStatus(c) == 'active').length;
    final expiredCount = allCoupons.where((c) => _getCouponStatus(c) == 'expired').length;
    final upcomingCount = allCoupons.where((c) => _getCouponStatus(c) == 'upcoming').length;
    final disabledCount = allCoupons.where((c) => c.status != 1).length;

    final filters = [
      FilterChipItem(
        id: 'all',
        label: 'all'.tr,
        count: allCoupons.length,
        icon: HeroiconsOutline.ticket,
      ),
      FilterChipItem(
        id: 'active',
        label: 'active'.tr,
        count: activeCount,
        icon: HeroiconsOutline.checkCircle,
      ),
      FilterChipItem(
        id: 'expired',
        label: 'expired'.tr,
        count: expiredCount,
        icon: HeroiconsOutline.clock,
      ),
      FilterChipItem(
        id: 'upcoming',
        label: 'upcoming'.tr,
        count: upcomingCount,
        icon: HeroiconsOutline.calendar,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: FilterChipRow(
        items: filters,
        selectedId: _selectedFilter,
        onSelected: (id) => setState(() => _selectedFilter = id),
      ),
    );
  }

  List<CouponBodyModel> _getFilteredCoupons(List<CouponBodyModel> coupons) {
    if (_selectedFilter == 'all') return coupons;

    return coupons.where((coupon) {
      final status = _getCouponStatus(coupon);
      if (_selectedFilter == 'disabled') {
        return coupon.status != 1;
      }
      return status == _selectedFilter && coupon.status == 1;
    }).toList();
  }

  String _getCouponStatus(CouponBodyModel coupon) {
    if (coupon.status != 1) return 'disabled';

    try {
      final now = DateTime.now();
      final startDate = DateTime.parse(coupon.startDate!);
      final expireDate = DateTime.parse(coupon.expireDate!);

      if (now.isBefore(startDate)) return 'upcoming';
      if (now.isAfter(expireDate)) return 'expired';
      return 'active';
    } catch (e) {
      return 'active';
    }
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            HeroiconsOutline.funnel,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            'no_coupons_for_filter'.tr,
            style: robotoMedium.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          TextButton(
            onPressed: () => setState(() => _selectedFilter = 'all'),
            child: Text('show_all'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(
    BuildContext context,
    CouponBodyModel coupon,
    CouponController controller,
  ) {
    final bool isDark = Get.isDarkMode;
    final status = _getCouponStatus(coupon);
    final statusConfig = _getStatusConfig(status);
    final bool isEnabled = coupon.status == 1;
    final bool isPercent = coupon.discountType == 'percent';
    final bool isFreeDelivery = coupon.couponType == 'free_delivery';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            border: Border.all(
              color: statusConfig.color.withOpacity(0.3),
            ),
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
              onTap: () => Get.dialog(
                CouponCardDialogueWidget(
                  couponBody: coupon,
                  index: controller.couponList!.indexOf(coupon),
                ),
                barrierDismissible: true,
                useSafeArea: true,
              ),
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              child: Row(
                children: [
                  // Left side - Discount section
                  Container(
                    width: 100,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radiusMedium),
                        bottomLeft: Radius.circular(Dimensions.radiusMedium),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isFreeDelivery)
                          Icon(
                            HeroiconsOutline.truck,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          )
                        else
                          Text(
                            isPercent
                                ? '${coupon.discount}%'
                                : PriceConverter.convertPrice(
                                    double.parse(coupon.discount.toString()),
                                  ),
                            style: robotoBold.copyWith(
                              fontSize: isPercent ? 28 : 20,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          isFreeDelivery ? 'free_delivery'.tr : 'off'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side - Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Code chip
                              _buildCodeChip(context, coupon.code!),
                              const Spacer(),
                              // Status badge
                              _buildStatusBadge(statusConfig),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Title
                          if (coupon.title != null && coupon.title!.isNotEmpty)
                            Text(
                              coupon.title!,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 8),

                          // Date range
                          Row(
                            children: [
                              Icon(
                                HeroiconsOutline.calendar,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${DateConverter.stringToLocalDateOnly(coupon.startDate!)} - ${DateConverter.stringToLocalDateOnly(coupon.expireDate!)}',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Min purchase & usage
                          Row(
                            children: [
                              Icon(
                                HeroiconsOutline.shoppingCart,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${'min'.tr}: ${PriceConverter.convertPrice(double.parse(coupon.minPurchase.toString()))}',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Colors.grey[500],
                                ),
                              ),
                              if (coupon.totalUses != null && coupon.limit != null) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  HeroiconsOutline.users,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${coupon.totalUses}/${coupon.limit}',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Usage progress
                          if (coupon.totalUses != null && coupon.limit != null && coupon.limit! > 0) ...[
                            const SizedBox(height: 8),
                            _buildUsageProgress(
                              coupon.totalUses!,
                              coupon.limit!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Actions menu
                  _buildActionsMenu(context, coupon, controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeChip(BuildContext context, String code) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        Get.snackbar(
          'copied'.tr,
          'coupon_code_copied'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              HeroiconsOutline.clipboard,
              size: 14,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(_StatusConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        config.label,
        style: robotoMedium.copyWith(
          fontSize: 10,
          color: config.color,
        ),
      ),
    );
  }

  Widget _buildUsageProgress(int used, int limit) {
    final progress = (used / limit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.8 ? AppColors.warning : Theme.of(context).primaryColor,
          ),
          borderRadius: BorderRadius.circular(2),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildActionsMenu(
    BuildContext context,
    CouponBodyModel coupon,
    CouponController controller,
  ) {
    final bool isEnabled = coupon.status == 1;

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(
        HeroiconsOutline.ellipsisVertical,
        color: Colors.grey[500],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      offset: const Offset(-10, 40),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                isEnabled ? HeroiconsOutline.eyeSlash : HeroiconsOutline.eye,
                size: 20,
                color: isEnabled ? AppColors.warning : AppColors.success,
              ),
              const SizedBox(width: 10),
              Text(isEnabled ? 'disable'.tr : 'enable'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                HeroiconsOutline.pencilSquare,
                size: 20,
                color: AppColors.info,
              ),
              const SizedBox(width: 10),
              Text('edit'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                HeroiconsOutline.trash,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: 10),
              Text('delete'.tr, style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'toggle':
            controller.changeStatus(coupon.id, !isEnabled).then((success) {
              if (success) controller.getCouponList();
            });
            break;
          case 'edit':
            Get.dialog(const CustomLoaderWidget());
            controller.getCouponDetails(coupon.id!).then((details) {
              Get.back();
              if (details != null) {
                Get.to(() => AddCouponScreen(coupon: details));
              }
            });
            break;
          case 'delete':
            showCustomBottomSheet(
              child: CouponDeleteBottomSheet(couponId: coupon.id!),
            );
            break;
        }
      },
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'active':
        return _StatusConfig(AppColors.success, 'active'.tr);
      case 'expired':
        return _StatusConfig(AppColors.error, 'expired'.tr);
      case 'upcoming':
        return _StatusConfig(AppColors.info, 'upcoming'.tr);
      case 'disabled':
        return _StatusConfig(AppColors.gray400, 'disabled'.tr);
      default:
        return _StatusConfig(AppColors.gray400, status);
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;

  _StatusConfig(this.color, this.label);
}
