import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/common/widgets/custom_image_widget.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_model.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:mnjood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InfoCardWidget extends StatelessWidget {
  final String title;
  final String image;
  final String? name;
  final DeliveryAddress? addressModel;
  final String? phone;
  final String? latitude;
  final String? longitude;
  final bool showButton;
  final bool isDelivery;
  final OrderModel? orderModel;
  final Function? messageOnTap;
  final bool isRestaurant;
  const InfoCardWidget({super.key, required this.title, required this.image, required this.name, required this.addressModel, required this.phone,
    required this.latitude, required this.longitude, required this.showButton, this.isDelivery = false, this.orderModel, this.messageOnTap, this.isRestaurant = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Title row with icon
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isRestaurant ? HeroiconsOutline.buildingStorefront : HeroiconsOutline.user,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: robotoMedium.copyWith(fontSize: 14, color: Theme.of(context).hintColor)),
        ]),
        const SizedBox(height: 16),

        (name != null && name!.isNotEmpty) ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

          // Profile image
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 2),
            ),
            child: ClipOval(child: CustomImageWidget(
              image: image,
              height: 56, width: 56, fit: BoxFit.cover,
            )),
          ),
          const SizedBox(width: 14),

          // Name and address
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(name ?? '', style: robotoBold.copyWith(fontSize: 16)),
            const SizedBox(height: 4),

            Row(children: [
              Icon(HeroiconsOutline.mapPin, size: 14, color: Theme.of(context).hintColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  addressModel?.address ?? 'location_n_a'.tr,
                  style: robotoRegular.copyWith(fontSize: 13, color: Theme.of(context).hintColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),

            isRestaurant ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                Icon(HeroiconsSolid.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  '3.3',
                  style: robotoMedium.copyWith(fontSize: 13),
                ),
              ]),
            ) : const SizedBox(),

          ])),

        ]) : Center(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Text('no_restaurant_data_found'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        )),

        // Action buttons
        if (showButton && name != null && name!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(children: [
            // Chat button
            Expanded(
              child: _ActionButton(
                icon: HeroiconsOutline.chatBubbleLeftRight,
                label: 'chat'.tr,
                color: Colors.blue,
                onTap: messageOnTap as void Function()?,
              ),
            ),
            const SizedBox(width: 10),

            // Call button
            if (orderModel != null)
              Expanded(
                child: _ActionButton(
                  icon: HeroiconsOutline.phone,
                  label: 'call'.tr,
                  color: Colors.green,
                  onTap: () async {
                    if(await canLaunchUrlString('tel:$phone')) {
                      launchUrlString('tel:$phone', mode: LaunchMode.externalApplication);
                    } else {
                      showCustomSnackBar('invalid_phone_number_found');
                    }
                  },
                ),
              ),
            if (orderModel != null) const SizedBox(width: 10),

            // Direction button
            Expanded(
              child: _ActionButton(
                icon: HeroiconsOutline.mapPin,
                label: 'direction'.tr,
                color: Theme.of(context).primaryColor,
                onTap: () async {
                  String url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&mode=d';
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url, mode: LaunchMode.externalApplication);
                  } else {
                    throw '${'could_not_launch'.tr} $url';
                  }
                },
              ),
            ),
          ]),
        ],

      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: robotoMedium.copyWith(fontSize: 13, color: color),
            ),
          ],
        ),
      ),
    );
  }
}