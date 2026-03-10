import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/cart/widgets/cart_product_widget.dart';
import 'package:mnjood/features/cart/widgets/cart_suggested_item_view_widget.dart';
import 'package:mnjood/features/cart/widgets/checkout_button_widget.dart';
import 'package:mnjood/features/cart/widgets/pricing_view_widget.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/no_data_screen_widget.dart';
import 'package:mnjood/common/widgets/not_logged_in_screen.dart';
import 'package:mnjood/common/widgets/web_constrained_box.dart';
import 'package:mnjood/common/widgets/web_page_title_widget.dart';
import 'package:mnjood/features/restaurant/screens/restaurant_screen.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  final bool fromReorder;
  final bool fromDineIn;
  const CartScreen({super.key, required this.fromNav, this.fromReorder = false, this.fromDineIn = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initCall();
  }

  Future<void> initCall() async {
    Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
    Get.find<CheckoutController>().setInstruction(-1, willUpdate: false);
    await Get.find<CartController>().getCartDataOnline();
    if(Get.find<CartController>().cartList.isNotEmpty){
      final firstProduct = Get.find<CartController>().cartList[0].product;
      if(firstProduct != null && firstProduct.restaurantId != null) {
        final currentRestaurant = Get.find<RestaurantController>().restaurant;
        if(currentRestaurant == null || currentRestaurant.id != firstProduct.restaurantId) {
          Get.find<RestaurantController>().makeEmptyRestaurant(willUpdate: false);
        }
        await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: firstProduct.restaurantId, name: null), fromCart: true, businessType: firstProduct.businessType);
        Get.find<CartController>().calculationCart();
        if(Get.find<CartController>().addCutlery){
          Get.find<CartController>().updateCutlery(isUpdate: false);
        }
        if(Get.find<CartController>().needExtraPackage){
          Get.find<CartController>().toggleExtraPackage(willUpdate: false);
        }
        Get.find<RestaurantController>().getCartRestaurantSuggestedItemList(firstProduct.restaurantId);
        showReferAndEarnSnackBar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'my_cart'.tr, isBackButtonExist: (isDesktop || !widget.fromNav)),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: !AuthHelper.isLoggedIn() ? NotLoggedInScreen(callBack: (bool value) {
        initCall();
        setState(() {});
      }) : GetBuilder<RestaurantController>(builder: (restaurantController) {
        return GetBuilder<CartController>(builder: (cartController) {

          bool isRestaurantOpen = true;

          if(restaurantController.restaurant != null) {
            isRestaurantOpen = restaurantController.isRestaurantOpenNow(restaurantController.restaurant?.active ?? true, restaurantController.restaurant?.schedules);
          }

          double distance = Get.find<RestaurantController>().getRestaurantDistance(
            LatLng(double.parse(restaurantController.restaurant?.latitude ?? '0'), double.parse(restaurantController.restaurant?.longitude ?? '0')),
          );

          return (cartController.isLoading && widget.fromReorder) ? const Center(
            child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
          ) : cartController.cartList.isNotEmpty ? Column(
            children: [
              Expanded(
                child: isDesktop ? _buildDesktopView(cartController, restaurantController, isRestaurantOpen, distance, isDesktop)
                    : _buildMobileView(cartController, restaurantController, isRestaurantOpen, distance),
              ),

              // Sticky checkout button
              isDesktop ? const SizedBox.shrink() : CheckoutButtonWidget(cartController: cartController, availableList: cartController.availableList, isRestaurantOpen: isRestaurantOpen, fromDineIn: widget.fromDineIn),
            ],
          ) : SingleChildScrollView(child: FooterViewWidget(child: NoDataScreen(isEmptyCart: true, title: 'you_have_not_add_to_cart_yet'.tr)));
        },
        );
      }),
    );
  }

  Widget _buildMobileView(CartController cartController, RestaurantController restaurantController, bool isRestaurantOpen, double distance) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Store Header Card
        _buildStoreHeader(restaurantController, distance, cartController),

        // Restaurant closed warning
        if (!isRestaurantOpen && restaurantController.restaurant != null)
          _buildClosedWarning(restaurantController, cartController),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Product List
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          itemCount: cartController.cartList.length,
          itemBuilder: (context, index) {
            return CartProductWidget(
              cart: cartController.cartList[index], cartIndex: index, addOns: cartController.addOnsList[index],
              isAvailable: cartController.availableList[index], isRestaurantOpen: isRestaurantOpen,
            );
          },
        ),

        // Clear cart / Add more button
        if (!isRestaurantOpen)
          _buildClearCartButton(cartController)
        else
          _buildAddMoreButton(cartController),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Suggested Items
        CartSuggestedItemViewWidget(cartList: cartController.cartList),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Order Summary Card
        _buildOrderSummaryCard(cartController, restaurantController),

        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Pricing extras (cutlery, packaging, etc.)
        PricingViewWidget(cartController: cartController, isRestaurantOpen: isRestaurantOpen, fromDineIn: widget.fromDineIn),

        const SizedBox(height: Dimensions.paddingSizeDefault),
      ]),
    );
  }

  Widget _buildDesktopView(CartController cartController, RestaurantController restaurantController, bool isRestaurantOpen, double distance, bool isDesktop) {
    bool suggestionEmpty = (restaurantController.suggestedItems != null && (restaurantController.suggestedItems?.isEmpty ?? true));

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: FooterViewWidget(
        child: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WebScreenTitleWidget(title: 'my_cart'.tr),

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  flex: 6,
                  child: Column(children: [

                    _buildStoreHeader(restaurantController, distance, cartController),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        WebConstrainedBox(
                          dataLength: cartController.cartList.length, minLength: 5, minHeight: suggestionEmpty ? 0.6 : 0.3,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            if (!isRestaurantOpen && restaurantController.restaurant != null)
                              _buildDesktopClosedWarning(restaurantController, cartController),

                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                itemCount: cartController.cartList.length,
                                itemBuilder: (context, index) {
                                  return CartProductWidget(
                                    cart: cartController.cartList[index], cartIndex: index, addOns: cartController.addOnsList[index],
                                    isAvailable: cartController.availableList[index], isRestaurantOpen: isRestaurantOpen,
                                  );
                                },
                              ),
                            ),

                            if (!isRestaurantOpen) const SizedBox() else _buildAddMoreButton(cartController),
                            const SizedBox(height: 8),
                          ]),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    CartSuggestedItemViewWidget(cartList: cartController.cartList),
                  ]),
                ),
                const SizedBox(width: Dimensions.paddingSizeLarge),

                Expanded(flex: 4, child: PricingViewWidget(cartController: cartController, isRestaurantOpen: isRestaurantOpen, fromDineIn: widget.fromDineIn)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreHeader(RestaurantController restaurantController, double distance, CartController cartController) {
    if (restaurantController.restaurant == null) {
      return Shimmer(child: Container(
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
        height: 60, width: double.infinity,
        decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
      ));
    }

    return Container(
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () {
          final product = cartController.cartList.isNotEmpty ? cartController.cartList[0].product : null;
          if (product != null) {
            Get.toNamed(
              RouteHelper.getRestaurantRoute(product.restaurantId, businessType: product.businessType),
              arguments: RestaurantScreen(restaurant: Restaurant(id: product.restaurantId, businessType: product.businessType)),
            );
          }
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Row(children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                image: restaurantController.restaurant?.logoFullUrl ?? '',
                height: 50, width: 50, fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                restaurantController.restaurant?.name ?? '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(children: [
                Icon(HeroiconsOutline.clock, color: Theme.of(context).disabledColor, size: 14),
                const SizedBox(width: 3),
                Text(restaurantController.restaurant?.deliveryTime ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                const SizedBox(width: 8),
                Icon(HeroiconsOutline.mapPin, color: Theme.of(context).disabledColor, size: 14),
                const SizedBox(width: 3),
                Text('${distance.toStringAsFixed(1)} ${'km'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
              ]),
            ]),
          ),

          Row(children: [
            Icon(HeroiconsSolid.star, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 3),
            Text((restaurantController.restaurant?.avgRating ?? 0).toStringAsFixed(1), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
          ]),

          const SizedBox(width: 4),
          Icon(HeroiconsOutline.chevronRight, size: 18, color: Theme.of(context).disabledColor),
        ]),
      ),
    );
  }

  Widget _buildClosedWarning(RestaurantController restaurantController, CartController cartController) {
    return Container(
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        Icon(HeroiconsOutline.exclamationTriangle, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Text(
            'currently_the_restaurant_is_unavailable'.tr,
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
          ),
        ),
      ]),
    );
  }

  Widget _buildDesktopClosedWarning(RestaurantController restaurantController, CartController cartController) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault),
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Text(
            'currently_the_restaurant_is_unavailable'.tr,
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
          ),
        ),
        InkWell(
          onTap: () => cartController.clearCartOnline(),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(width: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
            ),
            child: !cartController.isClearCartLoading ? Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(HeroiconsSolid.trash, color: Theme.of(context).colorScheme.error, size: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('remove_all_from_cart'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ]) : const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()),
          ),
        ),
      ]),
    );
  }

  Widget _buildClearCartButton(CartController cartController) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: CustomInkWellWidget(
          onTap: () => cartController.clearCartOnline(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(width: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
            ),
            child: !cartController.isClearCartLoading ? Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(HeroiconsSolid.trash, color: Theme.of(context).colorScheme.error, size: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(cartController.cartList.length > 1 ? 'remove_all_from_cart'.tr : 'remove_from_cart'.tr,
                style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
            ]) : const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreButton(CartController cartController) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: TextButton.icon(
        onPressed: () {
          final product = cartController.cartList[0].product;
          Get.toNamed(
            RouteHelper.getRestaurantRoute(product?.restaurantId, businessType: product?.businessType),
            arguments: RestaurantScreen(restaurant: Restaurant(id: product?.restaurantId, businessType: product?.businessType)),
          );
        },
        icon: Icon(HeroiconsOutline.plusCircle, color: Theme.of(context).primaryColor, size: 20),
        label: Text(
          'add_more_items'.tr,
          style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartController cartController, RestaurantController restaurantController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        _buildSummaryRow('item_price'.tr, cartController.itemPrice),

        if (cartController.variationPrice > 0) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildSummaryRow('variations'.tr, cartController.variationPrice, prefix: '(+) '),
        ],

        if (cartController.itemDiscountPrice > 0) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('discount'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
            restaurantController.restaurant != null ? Row(children: [
              Text('(-) ', style: robotoRegular.copyWith(color: const Color(0xFF2ECC71))),
              PriceConverter.convertAnimationPrice(cartController.itemDiscountPrice, textStyle: robotoRegular.copyWith(color: const Color(0xFF2ECC71))),
            ]) : Text('calculating'.tr, style: robotoRegular),
          ]),
        ],

        if (cartController.addOns > 0) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildSummaryRow('addons'.tr, cartController.addOns, prefix: '(+) '),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Divider(),
        ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('subtotal'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          PriceConverter.convertAnimationPrice(
            cartController.subTotal,
            textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
          ),
        ]),
      ]),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {String prefix = ''}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
      Row(children: [
        if (prefix.isNotEmpty) Text(prefix, style: robotoRegular),
        PriceConverter.convertAnimationPrice(amount, textStyle: robotoRegular),
      ]),
    ]);
  }

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if(Get.find<ProfileController>().userInfoModel != null && (Get.find<ProfileController>().userInfoModel?.isValidForDiscount ?? false)) {
      showCustomSnackBar(text, isError: false);
    }
  }

}
