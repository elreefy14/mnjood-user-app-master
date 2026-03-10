import 'package:mnjood_delivery/feature/order/screens/order_details_screen.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_model.dart';
import 'package:mnjood_delivery/helper/date_converter_helper.dart';
import 'package:mnjood_delivery/helper/price_converter_helper.dart';
import 'package:mnjood_delivery/helper/route_helper.dart';
import 'package:mnjood_delivery/util/color_resources.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class RunningOrderCardWidget extends StatelessWidget {
  final OrderModel orderModel;
  final int index;
  const RunningOrderCardWidget({super.key, required this.orderModel, required this.index});

  @override
  Widget build(BuildContext context) {
    int currentStep = _getCurrentStep(orderModel.orderStatus);
    Color statusColor = _getStatusColor(orderModel.orderStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: [
        // Header with status accent
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.12),
                statusColor.withOpacity(0.04),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            // Status icon with pulse effect
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
              ),
              child: Icon(_getStatusIcon(orderModel.orderStatus), color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(
                    '${'order'.tr} ',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                  ),
                  Text(
                    '#${orderModel.id}',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.access_time, size: 12, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text(
                    DateConverter.dateTimeStringToTime(orderModel.createdAt!),
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                  ),
                ]),
              ]),
            ),
            // Chat badge
            if ((orderModel.chatCount ?? 0) > 0 || orderModel.hasActiveChat == true)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.chat_bubble, size: 12, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 2),
                  Text('${orderModel.chatCount ?? 0}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
                ]),
              ),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _getStatusText(orderModel.orderStatus),
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: ColorResources.white),
              ),
            ),
          ]),
        ),

        // Progress stepper
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            _buildStepIndicator(context, 0, currentStep, Icons.check_circle_outline, 'accepted'.tr),
            _buildStepConnector(context, 0, currentStep),
            _buildStepIndicator(context, 1, currentStep, Icons.inventory_2_outlined, 'picked_up'.tr),
            _buildStepConnector(context, 1, currentStep),
            _buildStepIndicator(context, 2, currentStep, Icons.delivery_dining, 'on_way'.tr),
            _buildStepConnector(context, 2, currentStep),
            _buildStepIndicator(context, 3, currentStep, Icons.where_to_vote, 'delivered'.tr),
          ]),
        ),

        // Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 1,
          color: Theme.of(context).hintColor.withOpacity(0.1),
        ),

        // Location info
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Restaurant (Pickup)
            _buildLocationRow(
              context,
              icon: Icons.store_rounded,
              iconBgColor: Theme.of(context).primaryColor,
              label: 'pickup_from'.tr,
              address: orderModel.restaurantName ?? 'restaurant'.tr,
              phone: orderModel.restaurantPhone,
              lat: orderModel.restaurantLat,
              lng: orderModel.restaurantLng,
            ),

            // Route line
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(children: [
                Column(
                  children: List.generate(4, (i) => Container(
                    width: 2,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )),
                ),
                const SizedBox(width: 16),
                // Distance indicator (if available)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    Icon(Icons.route, size: 12, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(
                      'delivery_route'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ]),
                ),
              ]),
            ),

            // Customer (Delivery)
            _buildLocationRow(
              context,
              icon: Icons.location_on_rounded,
              iconBgColor: ColorResources.green,
              label: 'deliver_to'.tr,
              address: orderModel.deliveryAddress?.address ?? 'no_address'.tr,
              phone: orderModel.deliveryAddress?.contactPersonNumber,
              lat: orderModel.deliveryAddress?.latitude,
              lng: orderModel.deliveryAddress?.longitude,
            ),
          ]),
        ),

        // Order summary bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildSummaryItem(context, Icons.shopping_bag_outlined, '${orderModel.detailsCount} ${'items'.tr}'),
            _buildSummaryDivider(context),
            _buildSummaryItem(
              context,
              orderModel.paymentMethod == 'cash_on_delivery' ? Icons.money : Icons.credit_card,
              orderModel.paymentMethod == 'cash_on_delivery' ? 'COD' : 'paid'.tr,
              highlight: orderModel.paymentMethod == 'cash_on_delivery',
            ),
            _buildSummaryDivider(context),
            _buildSummaryItem(
              context,
              Icons.receipt_long_outlined,
              PriceConverter.convertPrice(orderModel.orderAmount),
              isBold: true,
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // Action button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.toNamed(
                RouteHelper.getOrderDetailsRoute(orderModel.id),
                arguments: OrderDetailsScreen(orderId: orderModel.id, isRunningOrder: true, orderIndex: index),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    'view_details'.tr,
                    style: robotoBold.copyWith(color: ColorResources.white, fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ColorResources.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: ColorResources.white, size: 16),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int step, int currentStep, IconData icon, String label) {
    bool isCompleted = step < currentStep;
    bool isCurrent = step == currentStep;
    Color activeColor = isCompleted ? ColorResources.green : (isCurrent ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withOpacity(0.3));

    return Expanded(
      child: Column(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent ? activeColor : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: activeColor,
              width: isCompleted || isCurrent ? 0 : 2,
            ),
            boxShadow: isCompleted || isCurrent ? [
              BoxShadow(
                color: activeColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isCurrent ? ColorResources.white : Theme.of(context).hintColor.withOpacity(0.5),
            size: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: 9,
            color: isCompleted || isCurrent ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }

  Widget _buildStepConnector(BuildContext context, int step, int currentStep) {
    bool isCompleted = step < currentStep;
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? const LinearGradient(colors: [ColorResources.green, ColorResources.green])
              : LinearGradient(colors: [
                  Theme.of(context).hintColor.withOpacity(0.2),
                  Theme.of(context).hintColor.withOpacity(0.2),
                ]),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required String label,
    required String address,
    String? phone,
    String? lat,
    String? lng,
  }) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBgColor.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconBgColor, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            label,
            style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 2),
          Text(
            address,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ]),
      ),
      // Action buttons
      if (phone != null && phone.isNotEmpty)
        _buildQuickAction(
          context,
          icon: Icons.phone_rounded,
          color: ColorResources.green,
          onTap: () => _makePhoneCall(phone),
        ),
      const SizedBox(width: 8),
      _buildQuickAction(
        context,
        icon: Icons.navigation_rounded,
        color: Theme.of(context).primaryColor,
        onTap: () => _openMap(lat, lng),
      ),
    ]);
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, IconData icon, String text, {bool highlight = false, bool isBold = false}) {
    return Row(children: [
      Icon(
        icon,
        size: 16,
        color: highlight ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
      ),
      const SizedBox(width: 6),
      Text(
        text,
        style: isBold
            ? robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
            : robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
      ),
    ]);
  }

  Widget _buildSummaryDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      color: Theme.of(context).hintColor.withOpacity(0.15),
    );
  }

  int _getCurrentStep(String? status) {
    switch (status) {
      case 'accepted':
        return 0;
      case 'arrived_at_store':
      case 'confirmed':
      case 'processing':
      case 'handover':
        return 1;
      case 'picked_up':
        return 2;
      case 'arrived_at_customer':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 0;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
      case 'accepted':
      case 'confirmed':
      case 'processing':
      case 'handover':
        return Theme.of(Get.context!).primaryColor;
      case 'arrived_at_store':
      case 'arrived_at_customer':
        return Colors.amber;
      case 'picked_up':
      case 'delivered':
        return ColorResources.green;
      case 'canceled':
        return ColorResources.red;
      default:
        return Theme.of(Get.context!).hintColor;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'accepted':
      case 'confirmed':
        return Icons.thumb_up_rounded;
      case 'arrived_at_store':
        return Icons.store_rounded;
      case 'processing':
      case 'handover':
        return Icons.inventory_2_rounded;
      case 'picked_up':
        return Icons.delivery_dining;
      case 'arrived_at_customer':
        return Icons.location_on_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'canceled':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'accepted':
        return 'accepted'.tr;
      case 'arrived_at_store':
        return 'arrived_at_store'.tr;
      case 'confirmed':
        return 'confirmed'.tr;
      case 'processing':
        return 'processing'.tr;
      case 'handover':
        return 'ready'.tr;
      case 'picked_up':
        return 'on_way'.tr;
      case 'arrived_at_customer':
        return 'arrived_at_customer'.tr;
      case 'delivered':
        return 'delivered'.tr;
      case 'canceled':
        return 'canceled'.tr;
      default:
        return status?.toUpperCase() ?? '';
    }
  }

  void _makePhoneCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _openMap(String? lat, String? lng) async {
    if (lat != null && lng != null) {
      final Uri launchUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
