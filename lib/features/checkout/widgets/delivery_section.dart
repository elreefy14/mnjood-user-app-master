import 'package:mnjood/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood/common/widgets/custom_text_field_widget.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/checkout/widgets/delivery_info_fields.dart';
import 'package:mnjood/features/checkout/widgets/saved_address_bottom_sheet.dart';
import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/helper/address_helper.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class DeliverySection extends StatefulWidget {
  final CheckoutController checkoutController;
  final LocationController locationController;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  const DeliverySection({super.key, required this.checkoutController,
    required this.locationController, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode, required this.guestEmailController, required this.guestEmailNode});

  @override
  State<DeliverySection> createState() => _DeliverySectionState();
}

class _DeliverySectionState extends State<DeliverySection> {

  @override
  void initState() {
    super.initState();
    widget.checkoutController.setShowMoreDetails(false, willUpdate: false);
    widget.checkoutController.insertAddresses(AddressHelper.getAddressFromSharedPref());
  }

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    bool takeAway = (widget.checkoutController.orderType == 'take_away');
    bool isDineIn = (widget.checkoutController.orderType == 'dine_in');
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return Column(children: [
        isGuestLoggedIn || isDineIn ? DeliveryInfoFields(
          checkoutController: widget.checkoutController, guestNumberNode: widget.guestNumberNode,
          guestNameTextEditingController: widget.guestNameTextEditingController,
          guestNumberTextEditingController: widget.guestNumberTextEditingController,
          guestEmailController: widget.guestEmailController, guestEmailNode: widget.guestEmailNode,
        ) : !takeAway && !isDineIn ? Container(
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Icon(HeroiconsOutline.mapPin, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text('deliver_to'.tr, style: robotoSemiBold),
              ]),

              InkWell(
                onTap: (){
                  if(isDesktop){
                    Get.dialog(
                      Dialog(child: SavedAddressBottomSheet()),
                    );
                  }else{
                    showCustomBottomSheet(child: SavedAddressBottomSheet());
                  }
                },
                child: Text('change'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
              ),
            ]),
            Divider(height: 25, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

            InkWell(
              onTap: (){
                if(isDesktop){
                  Get.dialog(
                    Dialog(child: SavedAddressBottomSheet()),
                  );
                }else{
                  showCustomBottomSheet(child: SavedAddressBottomSheet());
                }
              },
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.15), width: 1),
                ),
                child: Row(children: [
                  Image.asset(
                    checkoutController.addressType == 'home' ? Images.homeIcon : checkoutController.addressType == 'office' ? Images.workIcon : Images.otherIcon,
                    color: Theme.of(context).primaryColor,
                    height: ResponsiveHelper.isDesktop(context) ? 25 : 20, width: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      checkoutController.addressType.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      checkoutController.addressController.text,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ])),

                  Icon(HeroiconsOutline.chevronRight, size: 20, color: Theme.of(context).hintColor),
                ]),
              ),
            ),
            SizedBox(height: checkoutController.streetNumberController.text.isNotEmpty || checkoutController.houseController.text.isNotEmpty || checkoutController.floorController.text.isNotEmpty ? Dimensions.paddingSizeDefault : 0),

            checkoutController.streetNumberController.text.isNotEmpty || checkoutController.houseController.text.isNotEmpty || checkoutController.floorController.text.isNotEmpty ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              checkoutController.streetNumberController.text.isNotEmpty ? RichText(
                text: TextSpan(
                  text: '${'street'.tr} : ',
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  children: [
                    TextSpan(
                      text: checkoutController.streetNumberController.text,
                      style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ) : SizedBox(),

              checkoutController.streetNumberController.text.isNotEmpty ? Container(
                height: 15, width: 1,
                color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
              ) : const SizedBox(),

              checkoutController.houseController.text.isNotEmpty ? RichText(
                text: TextSpan(
                  text: '${'house'.tr} : ',
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  children: [
                    TextSpan(
                      text: checkoutController.houseController.text,
                      style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ) : SizedBox(),

              checkoutController.houseController.text.isNotEmpty ? Container(
                height: 15, width: 1,
                color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
              ) : SizedBox(),

              checkoutController.floorController.text.isNotEmpty ? RichText(
                text: TextSpan(
                  text: '${'floor'.tr} : ',
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  children: [
                    TextSpan(
                      text: checkoutController.floorController.text,
                      style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ) : SizedBox(),
            ]) : Center(
              child: Column(children: [

                Visibility(
                  visible: !checkoutController.showMoreDetails,
                  child: Padding(
                    padding: EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () {
                        checkoutController.setShowMoreDetails(true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Theme.of(context).primaryColor),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(HeroiconsOutline.plus, size: 16, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 4),
                          Text('add_more_details'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                        ]),
                      ),
                    ),
                  ),
                ),

                Visibility(
                  visible: checkoutController.showMoreDetails,
                  child: Column(children: [
                    SizedBox(height: Dimensions.paddingSizeLarge),

                    !ResponsiveHelper.isDesktop(context) ? CustomTextFieldWidget(
                      hintText: 'write_street_number'.tr,
                      labelText: 'street_number'.tr,
                      inputType: TextInputType.streetAddress,
                      focusNode: widget.checkoutController.streetNode,
                      nextFocus: widget.checkoutController.houseNode,
                      controller: widget.checkoutController.streetNumberController,
                    ) : const SizedBox(),
                    SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

                    Row(
                      children: [
                        ResponsiveHelper.isDesktop(context) ? Expanded(
                          child: CustomTextFieldWidget(
                            hintText: 'write_street_number'.tr,
                            labelText: 'street_number'.tr,
                            inputType: TextInputType.streetAddress,
                            focusNode: widget.checkoutController.streetNode,
                            nextFocus: widget.checkoutController.houseNode,
                            controller: widget.checkoutController.streetNumberController,
                            showTitle: false,
                          ),
                        ) : const SizedBox(),
                        SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

                        Expanded(
                          child: CustomTextFieldWidget(
                            hintText: 'write_house_number'.tr,
                            labelText: 'house'.tr,
                            inputType: TextInputType.text,
                            focusNode: widget.checkoutController.houseNode,
                            nextFocus: widget.checkoutController.floorNode,
                            controller: widget.checkoutController.houseController,
                            showTitle: false,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: CustomTextFieldWidget(
                            hintText: 'write_floor_number'.tr,
                            labelText: 'floor'.tr,
                            inputType: TextInputType.text,
                            focusNode: widget.checkoutController.floorNode,
                            inputAction: TextInputAction.done,
                            controller: widget.checkoutController.floorController,
                            showTitle: false,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),

              ]),
            ),

          ]),
        ) : const SizedBox(),
      ]);
    });
  }
}
