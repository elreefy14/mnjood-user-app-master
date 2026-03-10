import 'package:mnjood_vendor/features/order/domain/models/order_model.dart';
import 'package:mnjood_vendor/features/order/screens/order_details_screen.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/app_colors.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/icon_mapper.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';

class OrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool hasDivider;
  final bool isRunning;
  final bool showStatus;
  const OrderWidget({
    super.key,
    required this.orderModel,
    required this.hasDivider,
    required this.isRunning,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = orderModel.orderStatus ?? 'pending';
    final statusColor = AppColors.getOrderStatusColor(status);
    final statusBgColor = AppColors.getOrderStatusBgColor(status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => Get.toNamed(
        RouteHelper.getOrderDetailsRoute(orderModel.id),
        arguments: OrderDetailsScreen(
          orderModel: orderModel,
          isRunningOrder: isRunning,
          orderId: orderModel.id ?? 0,
        ),
      ),
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isRunning
                ? statusColor.withValues(alpha: 0.3)
                : Theme.of(context).hintColor.withValues(alpha: 0.2),
            width: isRunning ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Order ID, Status, and Status Badge
            _buildHeader(context, status, statusColor, statusBgColor),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).hintColor.withValues(alpha: 0.1),
            ),

            // Order Details Body
            _buildBody(context, status, statusColor),

            // Footer with Payment and Amount
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String status,
    Color statusColor,
    Color statusBgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.radiusDefault),
        ),
      ),
      child: Row(
        children: [
          // Order Status Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Icon(
              IconMapper.getOrderStatusIcon(status),
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          // Order ID and Items Count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('order'.tr, style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall,
                    )),
                    Text(
                      ' #${orderModel.id}',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      HeroiconsOutline.shoppingBag,
                      size: 14,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${orderModel.detailsCount ?? 0} ${(orderModel.detailsCount ?? 0) < 2 ? 'item'.tr : 'items'.tr}',
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chat Badge
          if ((orderModel.chatCount ?? 0) > 0 || orderModel.hasActiveChat == true)
            Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.chat_bubble, size: 12, color: Theme.of(context).primaryColor),
                const SizedBox(width: 2),
                Text('${orderModel.chatCount ?? 0}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
              ]),
            ),

          // Status Badge
          if (showStatus || isRunning) _buildStatusBadge(context, status, statusColor, statusBgColor),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String status,
    Color statusColor,
    Color statusBgColor,
  ) {
    String displayStatus = status;
    if (orderModel.orderType == 'dine_in' && status == 'delivered') {
      displayStatus = 'served';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            displayStatus.tr.capitalizeFirst ?? displayStatus,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          // Left Side: Date/Time and Order Type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Time
                Row(
                  children: [
                    Icon(
                      HeroiconsOutline.calendar,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        orderModel.createdAt != null
                            ? DateConverter.dateTimeStringToDateTime(orderModel.createdAt!)
                            : '',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Order Type Badge
                _buildOrderTypeBadge(context),
              ],
            ),
          ),

          // Right Side: Customer info or scheduled time
          if (orderModel.customer != null || orderModel.scheduled == 1) ...[
            const SizedBox(width: Dimensions.paddingSizeSmall),
            _buildCustomerOrScheduleInfo(context),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderTypeBadge(BuildContext context) {
    final orderType = orderModel.orderType ?? 'delivery';
    IconData typeIcon;
    Color typeColor;

    switch (orderType.toLowerCase()) {
      case 'delivery':
        typeIcon = HeroiconsOutline.truck;
        typeColor = AppColors.info;
        break;
      case 'take_away':
        typeIcon = HeroiconsOutline.shoppingBag;
        typeColor = AppColors.primary;
        break;
      case 'dine_in':
        typeIcon = HeroiconsOutline.buildingStorefront;
        typeColor = AppColors.success;
        break;
      default:
        typeIcon = HeroiconsOutline.clipboardDocumentList;
        typeColor = Theme.of(context).primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(typeIcon, size: 14, color: typeColor),
          const SizedBox(width: 4),
          Text(
            orderType.tr.capitalizeFirst ?? orderType.replaceAll('_', ' '),
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerOrScheduleInfo(BuildContext context) {
    // Show scheduled indicator if scheduled
    if (orderModel.scheduled == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              HeroiconsOutline.clock,
              size: 14,
              color: AppColors.warning,
            ),
            const SizedBox(width: 4),
            Text(
              'scheduled'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      );
    }

    // Show customer initial if available
    if (orderModel.customer != null) {
      final customerName = '${orderModel.customer?.fName ?? ''} ${orderModel.customer?.lName ?? ''}'.trim();
      if (customerName.isNotEmpty) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Text(
                customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Text(
                customerName,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.03),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(Dimensions.radiusDefault),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Payment Method
          Row(
            children: [
              Icon(
                _getPaymentIcon(),
                size: 18,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(width: 6),
              Text(
                _getPaymentMethodText(),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(width: 8),
              _buildPaymentStatusBadge(context),
            ],
          ),

          // Amount
          Row(
            children: [
              PriceConverter.convertPriceWithSvg(
                orderModel.orderAmount,
                textStyle: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                HeroiconsOutline.chevronRight,
                size: 20,
                color: Theme.of(context).hintColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon() {
    switch (orderModel.paymentMethod?.toLowerCase()) {
      case 'cash_on_delivery':
      case 'cash':
        return HeroiconsOutline.banknotes;
      case 'wallet':
        return HeroiconsOutline.wallet;
      case 'digital_payment':
        return HeroiconsOutline.creditCard;
      default:
        return HeroiconsOutline.currencyDollar;
    }
  }

  String _getPaymentMethodText() {
    final method = orderModel.paymentMethod ?? '';
    switch (method.toLowerCase()) {
      case 'cash_on_delivery':
        return 'cod'.tr;
      case 'wallet':
        return 'wallet'.tr;
      case 'cash':
        return 'cash'.tr;
      case 'digital_payment':
        return 'digital'.tr;
      default:
        return method.replaceAll('_', ' ').capitalizeFirst ?? method;
    }
  }

  Widget _buildPaymentStatusBadge(BuildContext context) {
    final isPaid = orderModel.paymentStatus == 'paid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPaid ? 'paid'.tr : 'unpaid'.tr,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall - 1,
          color: isPaid ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}

/// Compact order card for dashboard views
class OrderWidgetCompact extends StatelessWidget {
  final OrderModel orderModel;
  final VoidCallback? onTap;

  const OrderWidgetCompact({
    super.key,
    required this.orderModel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = orderModel.orderStatus ?? 'pending';
    final statusColor = AppColors.getOrderStatusColor(status);

    return InkWell(
      onTap: onTap ?? () => Get.toNamed(
        RouteHelper.getOrderDetailsRoute(orderModel.id),
        arguments: OrderDetailsScreen(
          orderModel: orderModel,
          isRunningOrder: true,
          orderId: orderModel.id ?? 0,
        ),
      ),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${orderModel.id}',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${orderModel.detailsCount ?? 0} ${'items'.tr}',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            PriceConverter.convertPriceWithSvg(
              orderModel.orderAmount,
              textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ],
        ),
      ),
    );
  }
}
