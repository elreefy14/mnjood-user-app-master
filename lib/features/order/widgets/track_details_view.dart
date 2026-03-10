import 'package:mnjood/common/widgets/rating_bar_widget.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/features/order/widgets/address_details_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class TrackDetailsView extends StatelessWidget {
  final OrderModel track;
  final Function callback;
  const TrackDetailsView({super.key, required this.track, required this.callback});

  @override
  Widget build(BuildContext context) {
    double distance = 0;
    bool takeAway = track.orderType == 'take_away';
    if(track.deliveryMan != null) {
      distance = Geolocator.distanceBetween(
        double.parse(track.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
        double.parse(track.deliveryMan!.lat ?? '0'), double.parse(track.deliveryMan!.lng ?? '0'),
      ) / 1000;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        color: Theme.of(context).cardColor,
      ),
      alignment: Alignment.center,
      child: (!takeAway && track.deliveryMan == null) ? Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(children: [

          Text('estimate_delivery_time'.tr, style: robotoRegular),

          Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [

              Text(
                () {
                  int remaining = DateConverter.differenceInMinute(track.restaurant!.deliveryTime, track.createdAt, track.processingTime, track.scheduleAt);
                  if (remaining <= 0) return '0';
                  if (remaining < 5) return '$remaining';
                  return '${remaining - 5} - $remaining';
                }(),
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge), textDirection: TextDirection.ltr,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text('min'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
            ]),
          ),

        ]),
      ) : Column(children: [

        Container(
          height: 5, width: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Text('estimate_delivery_time'.tr, style: robotoRegular),

        Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [

            Text(
              () {
                int remaining = DateConverter.differenceInMinute(track.restaurant!.deliveryTime, track.createdAt, track.processingTime, track.scheduleAt);
                if (remaining <= 0) return '0';
                if (remaining < 5) return '$remaining';
                return '${remaining - 5} - $remaining';
              }(),
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge), textDirection: TextDirection.ltr,
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Text('min'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
          ]),
        ),

        Divider(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), thickness: 1, height: 30),

        takeAway ? InkWell(
          onTap: () async {
            String url ='https://www.google.com/maps/dir/?api=1&destination=${track.restaurant != null ? track.restaurant!.latitude : '0'}'
                ',${track.restaurant != null ? track.restaurant!.longitude : '0'}&mode=d';
            if (await canLaunchUrlString(url)) {
              Get.find<OrderController>().cancelTimer();
              await launchUrlString(url, mode: LaunchMode.externalApplication);
              Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: track.id.toString());
            }else {
              showCustomSnackBar('unable_to_launch_google_map'.tr);
            }
          },
          child: Column(children: [
            Icon(HeroiconsOutline.arrowUturnRight, size: 25, color: Theme.of(context).primaryColor),
            Text(
              'direction'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ]),
        ) : Column(children: [
          Image.asset(Images.route, height: 20, width: 20, color: Theme.of(context).primaryColor),
          Text(
            '${distance.toStringAsFixed(2)} ${'km'.tr}',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]),

        Row(children: [

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

          Flexible(
            child: Text(
              takeAway ? track.deliveryAddress!.address! : track.deliveryMan!.location!,
              style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),

        ]),

        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 3),
            color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            height: 20, width: 3,
          ),
        ),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

          Flexible(
            child: takeAway ? Text(track.restaurant != null ? track.restaurant!.address! : '',
              style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ) : AddressDetailsWidget(addressDetails: track.deliveryAddress),
          ),

        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        EnhancedRiderCard(
          track: track,
          takeAway: takeAway,
          onChatTap: callback as void Function()?,
        ),

      ]),
    );
  }
}

/// Enhanced Rider/Restaurant Card with animations and better UI
class EnhancedRiderCard extends StatefulWidget {
  final OrderModel track;
  final bool takeAway;
  final VoidCallback? onChatTap;

  const EnhancedRiderCard({
    super.key,
    required this.track,
    required this.takeAway,
    this.onChatTap,
  });

  @override
  State<EnhancedRiderCard> createState() => _EnhancedRiderCardState();
}

class _EnhancedRiderCardState extends State<EnhancedRiderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _makePhoneCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    HapticFeedback.lightImpact();
    if (await canLaunchUrlString('tel:$phone')) {
      launchUrlString('tel:$phone', mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('${'can_not_launch'.tr} $phone');
    }
  }

  void _handleChat() {
    HapticFeedback.lightImpact();
    widget.onChatTap?.call();
  }

  IconData _getVehicleIcon() {
    // Default to motorcycle for now - can be extended based on vehicle type data
    return Icons.delivery_dining;
  }

  @override
  Widget build(BuildContext context) {
    final isRestaurant = widget.takeAway;
    final deliveryMan = widget.track.deliveryMan;
    final restaurant = widget.track.restaurant;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: context.width,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    isRestaurant
                        ? HeroiconsSolid.buildingStorefront
                        : Icons.delivery_dining,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isRestaurant ? 'restaurant_details'.tr : 'delivery_man_details'.tr,
                    style: robotoBold.copyWith(
                      fontSize: 13,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Main content
              Row(
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CustomImageWidget(
                            image: isRestaurant
                                ? (restaurant?.logoFullUrl ?? '')
                                : (deliveryMan?.imageFullUrl ?? ''),
                            height: 52,
                            width: 52,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Online indicator for delivery man
                      if (!isRestaurant)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  // Info section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name with verified badge
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                isRestaurant
                                    ? (restaurant?.name ?? 'no_restaurant_data_found'.tr)
                                    : '${deliveryMan?.fName ?? ''} ${deliveryMan?.lName ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(fontSize: 15),
                              ),
                            ),
                            // Verified badge (if phone is available, consider verified)
                            if (!isRestaurant && deliveryMan?.phone != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  HeroiconsSolid.checkBadge,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Rating and vehicle type row
                        Row(
                          children: [
                            // Rating
                            Icon(
                              HeroiconsSolid.star,
                              size: 14,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isRestaurant
                                  ? (restaurant?.avgRating?.toStringAsFixed(1) ?? '0.0')
                                  : (deliveryMan?.avgRating?.toStringAsFixed(1) ?? '0.0'),
                              style: robotoMedium.copyWith(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${isRestaurant ? (restaurant?.ratingCount ?? 0) : (deliveryMan?.ratingCount ?? 0)})',
                              style: robotoRegular.copyWith(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),

                            // Vehicle type for delivery man
                            if (!isRestaurant) ...[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                width: 1,
                                height: 12,
                                color: Colors.grey[400],
                              ),
                              Icon(
                                _getVehicleIcon(),
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'delivery_man'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chat button (only for delivery orders, not takeaway)
                      if (Get.find<AuthController>().isLoggedIn() && !widget.takeAway)
                        _buildActionButton(
                          icon: HeroiconsSolid.chatBubbleLeftRight,
                          color: Theme.of(context).primaryColor,
                          onTap: _handleChat,
                        ),
                      const SizedBox(width: 8),
                      // Call button
                      _buildActionButton(
                        icon: HeroiconsSolid.phone,
                        color: Colors.green,
                        onTap: () => _makePhoneCall(
                          isRestaurant ? restaurant?.phone : deliveryMan?.phone,
                        ),
                      ),
                    ],
                  ),
                ],
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
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
      ),
    );
  }
}
