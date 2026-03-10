import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:mnjood/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/common/widgets/custom_tool_tip.dart';
import 'package:mnjood/common/widgets/discount_tag_widget.dart';
import 'package:mnjood/common/widgets/discount_tag_without_image_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_shimmer.dart';
import 'package:mnjood/helper/product_helper.dart';
import 'package:mnjood/common/widgets/quantity_button_widget.dart';
import 'package:mnjood/common/widgets/rating_bar_widget.dart';
import 'package:mnjood/common/widgets/readmore_widget.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/checkout/screens/checkout_screen.dart';
import 'package:mnjood/features/product/widgets/product_review_bottom_sheet.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/cart_helper.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/confirmation_dialog_widget.dart';
import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ProductBottomSheetWidget extends StatefulWidget {
  final Product? product;
  final bool isCampaign;
  final CartModel? cart;
  final int? cartIndex;
  final bool inRestaurantPage;
  final bool? fromReview;
  final String? businessType;
  final int? vendorId;
  const ProductBottomSheetWidget({super.key, required this.product, this.isCampaign = false, this.cart, this.cartIndex, this.inRestaurantPage = false, this.fromReview = false, this.businessType, this.vendorId});

  @override
  State<ProductBottomSheetWidget> createState() => _ProductBottomSheetWidgetState();
}

class _ProductBottomSheetWidgetState extends State<ProductBottomSheetWidget> {

  JustTheController tooTipController = JustTheController();

  final ScrollController scrollController = ScrollController();
  
  Product? product;

  @override
  void initState() {
    super.initState();

    _initCall();
  }
  
  Future<void> _initCall() async {
    if(widget.fromReview == true) {
      product = widget.product;
    } else {
      final productId = widget.product?.id;
      if (productId != null) {
        // Get vendor ID and business type for supermarket/pharmacy product details
        int? vendorId = widget.vendorId ?? widget.product?.restaurantId;
        String? businessType = widget.businessType;  // Use widget param first

        // Fallback to RestaurantController if businessType not provided
        if (businessType == null && widget.inRestaurantPage && Get.isRegistered<RestaurantController>()) {
          final restController = Get.find<RestaurantController>();
          vendorId = vendorId ?? restController.restaurant?.id;
          businessType = restController.restaurant?.businessType;
        }

        // DEBUG: Print to verify values
        debugPrint('=== ProductBottomSheet DEBUG ===');
        debugPrint('productId: $productId');
        debugPrint('vendorId: $vendorId');
        debugPrint('businessType: $businessType');
        debugPrint('inRestaurantPage: ${widget.inRestaurantPage}');

        await Get.find<ProductController>().getProductDetails(
          productId,
          widget.cart,
          isCampaign: widget.isCampaign,
          vendorId: vendorId,
          businessType: businessType,
        );
      }
      product = Get.find<ProductController>().product;
    }

    String? warning = Get.find<ProductController>().checkOutOfStockVariationSelected(product?.variations);
    if(warning != null) {
      showCustomSnackBar(warning);
    }
    if(product != null && (product!.variations?.isEmpty ?? true)) {
      Get.find<ProductController>().setExistInCart(product!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: GetBuilder<ProductController>(builder: (productController) {
        product = productController.product;
        if(productController.product == null) {
          return const ProductBottomSheetShimmer();
        }
        double price = product!.price ?? 0;
        double? discount = product!.discount;
        String? discountType = product!.discountType;

        // Override price when a unit is selected (supermarket/Mnjood Mart only)
        final selectedUnit = productController.selectedUnit;
        if (selectedUnit != null && selectedUnit.sellingPrice != null && (widget.businessType == 'supermarket' || product!.businessType == 'supermarket')) {
          price = selectedUnit.sellingPrice!;
          // Use unit's own discount if available, otherwise keep original product discount
          if (selectedUnit.discountedPrice != null && selectedUnit.discountedPrice! > 0 && selectedUnit.discountedPrice! < price) {
            discount = double.parse((price - selectedUnit.discountedPrice!).toStringAsFixed(2));
            discountType = 'amount';
          }
          // else: keep original product discount & discountType
        }

        double variationPrice = _getVariationPrice(product!, productController);
        double variationPriceWithDiscount = _getVariationPriceWithDiscount(product!, productController, discount, discountType);
        double priceWithDiscountForView = PriceConverter.convertWithDiscount(price, discount, discountType)!;
        double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;

        double addonsCost = _getAddonCost(product!, productController);
        List<AddOn> addOnIdList = _getAddonIdList(product!, productController);
        List<AddOns> addOnsList = _getAddonList(product!, productController);

        double priceWithAddonsVariationWithDiscount = addonsCost + (PriceConverter.convertWithDiscount(variationPrice + price , discount, discountType)! * productController.quantity!);
        double priceWithAddonsVariation = ((price + variationPrice) * productController.quantity!) + addonsCost;
        double priceWithVariation = price + variationPrice;
        bool isAvailable = ProductHelper.isAvailable(product!);

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          child: Stack(
            children: [

              Column( mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: GetPlatform.isIOS || GetPlatform.isDesktop ? Dimensions.paddingSizeLarge : 0),

                  Flexible(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: Dimensions.paddingSizeDefault, top: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault,
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                            ///Product
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                              (product!.imageFullUrl != null && product!.imageFullUrl!.isNotEmpty) ? InkWell(
                                onTap: widget.isCampaign ? null : () {
                                  if(!widget.isCampaign) {
                                    Get.toNamed(RouteHelper.getItemImagesRoute(product!));
                                  }
                                },
                                child: Stack(children: [

                                  Container(
                                    decoration: widget.businessType == 'pharmacy' ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ) : null,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      child: CustomImageWidget(
                                        image: '${product!.imageFullUrl}',
                                        width: ResponsiveHelper.isMobile(context) ? 100 : 140,
                                        height: ResponsiveHelper.isMobile(context) ? 100 : 140,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),


                                  // Pharmacy health badge
                                  if (widget.businessType == 'pharmacy')
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(Dimensions.radiusSmall),
                                            bottomRight: Radius.circular(Dimensions.radiusSmall),
                                          ),
                                        ),
                                        child: const Icon(
                                          HeroiconsSolid.heart,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                ]),
                              ) : const SizedBox.shrink(),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    product!.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if(widget.inRestaurantPage) {
                                        Get.back();
                                      }else {
                                        Get.offNamed(RouteHelper.getRestaurantRoute(product!.restaurantId, businessType: widget.businessType));
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (widget.businessType == 'pharmacy') ...[
                                            Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Icon(
                                                HeroiconsSolid.buildingStorefront,
                                                size: 12,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                          ],
                                          Flexible(
                                            child: Text(
                                              product!.restaurantName ?? '',
                                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  InkWell(
                                    onTap: (widget.isCampaign || (product?.reviewCount == 0)) ? null : () {
                                      Get.back();
                                      ResponsiveHelper.isMobile(context) ? showCustomBottomSheet(child: ProductReviewBottomSheet(product: product!), isDismissible: false, enableDrag: false) : Get.dialog(
                                        Dialog(child: ProductReviewBottomSheet(product: product!)),
                                      );
                                    },
                                    child: RatingBarWidget(rating: product!.avgRating, size: 15, ratingCount: widget.isCampaign ? product!.ratingCount : null, reviewCount: widget.isCampaign ? null : (product?.reviewCount ?? 0)),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Wrap(children: [
                                    price > priceWithDiscountForView ? PriceConverter.convertPriceWithSvg(
                                      price,
                                      textStyle: robotoMedium.copyWith(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                                      symbolColor: Theme.of(context).disabledColor,
                                      symbolSize: 12,
                                    ) : const SizedBox(),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    (product!.imageFullUrl != null && product!.imageFullUrl!.isNotEmpty)? const SizedBox.shrink()
                                      : DiscountTagWithoutImageWidget(discount: discount, discountType: discountType),

                                    PriceConverter.convertPriceWithSvg(
                                      priceWithDiscountForView,
                                      textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                      symbolSize: 14,
                                    ),

                                    (!widget.isCampaign && product!.stockType != null && product!.stockType != 'unlimited' && (product!.itemStock ?? 0) <= 0)
                                      ? Text(' (${'out_of_stock'.tr})', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error))
                                      : const SizedBox(),

                                    (!widget.isCampaign && product!.stockType != 'unlimited' && productController.quantity != 1 && productController.quantity! >= (product!.itemStock ?? 0))
                                      ? Text(' (${'only'.tr} ${product!.itemStock ?? 0} ${'item_available'.tr})', style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall))
                                      : const SizedBox(),

                                  ]),

                                ]),
                              ),

                              Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                widget.isCampaign ? const SizedBox(height: 25) : GetBuilder<FavouriteController>(builder: (favouriteController) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                    ),
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    margin: EdgeInsets.only(top: GetPlatform.isAndroid ? 0 : Dimensions.paddingSizeLarge),
                                    child: CustomFavouriteWidget(
                                      isWished: favouriteController.wishProductIdList.contains(product!.id),
                                      product: product, isRestaurant: false,
                                      businessType: widget.businessType,
                                    ),
                                  );
                                }),
                                SizedBox(height: (product!.isRestaurantHalalActive ?? false) && (product!.isHalalFood ?? false) ? 30 : 20),

                                (product!.isRestaurantHalalActive ?? false) && (product!.isHalalFood ?? false) ? Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: CustomToolTip(
                                    message: 'this_is_a_halal_food'.tr,
                                    preferredDirection: AxisDirection.up,
                                    tooltipController: tooTipController,
                                    child: Image.asset(Images.halalIcon, height: 35, width: 35),
                                  ),
                                ) : const SizedBox(),

                              ]),
                            ]),

                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            (product!.description != null && product!.description!.isNotEmpty) ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                  Text('description'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                  // Veg/Non-veg indicator removed

                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                ReadMoreText(
                                  product?.description ?? '',
                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.8)),
                                  trimMode: TrimMode.Line,
                                  trimLines: 3,
                                  colorClickableText: Theme.of(context).primaryColor,
                                  lessStyle: robotoRegular.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
                                  trimCollapsedText: 'see_more'.tr,
                                  trimExpandedText: ' ${'see_less'.tr}',
                                  moreStyle: robotoRegular.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeLarge),

                              ],
                            ) : const SizedBox(),

                            (product!.nutritionsName != null && product!.nutritionsName!.isNotEmpty) ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('nutrition_details'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Wrap(children: List.generate(product!.nutritionsName!.length, (index) {
                                  return Text(
                                    '${product!.nutritionsName![index]}${product!.nutritionsName!.length-1 == index ? '.' : ', '}',
                                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.8)),
                                  );
                                })),
                                const SizedBox(height: Dimensions.paddingSizeLarge),
                              ],
                            ) : const SizedBox(),

                            (product!.allergiesName != null && product!.allergiesName!.isNotEmpty) ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('allergic_ingredients'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Wrap(children: List.generate(product!.allergiesName!.length, (index) {
                                  return Text(
                                    '${product!.allergiesName![index]}${product!.allergiesName!.length-1 == index ? '.' : ', '}',
                                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.8)),
                                  );
                                })),
                                const SizedBox(height: Dimensions.paddingSizeLarge),
                              ],
                            ) : const SizedBox(),

                            // Pharmacy Details Section - Only for pharmacy products
                            if (widget.businessType == 'pharmacy') ...[
                              _buildPharmacyDetailsSection(context, product!),
                            ],

                            /// Unit Selector (supermarket/Mnjood Mart only)
                            if (product != null && product!.units != null && product!.units!.length > 1 && (widget.businessType == 'supermarket' || product!.businessType == 'supermarket')) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('select_unit'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                    Wrap(
                                      spacing: Dimensions.paddingSizeSmall,
                                      runSpacing: Dimensions.paddingSizeExtraSmall,
                                      children: List.generate(product!.units!.length, (index) {
                                        final unit = product!.units![index];
                                        final isSelected = productController.selectedUnitIndex == index;
                                        final isPurchasable = unit.isPurchasable ?? true;
                                        final unitLabel = Get.locale?.languageCode == 'ar' && unit.labelAr != null && unit.labelAr!.isNotEmpty
                                            ? unit.labelAr!
                                            : unit.label ?? unit.name ?? '';
                                        return ChoiceChip(
                                          label: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(unitLabel),
                                              if (unit.sellingPrice != null)
                                                Text(
                                                  PriceConverter.convertPrice(unit.effectivePrice ?? unit.sellingPrice!),
                                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                                                ),
                                            ],
                                          ),
                                          selected: isSelected,
                                          selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                          backgroundColor: isPurchasable ? null : Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                          labelStyle: robotoRegular.copyWith(
                                            color: !isPurchasable
                                                ? Theme.of(context).disabledColor
                                                : isSelected
                                                    ? Theme.of(context).primaryColor
                                                    : Theme.of(context).textTheme.bodyLarge!.color,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                            side: BorderSide(
                                              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                            ),
                                          ),
                                          onSelected: isPurchasable ? (selected) {
                                            if (selected) {
                                              productController.setSelectedUnit(index);
                                              productController.setExistInCartForBottomSheet(product!, productController.selectedVariations);
                                            }
                                          } : null,
                                        );
                                      }),
                                    ),
                                    if (productController.selectedUnit?.minOrderQty != null && productController.selectedUnit!.minOrderQty! > 1)
                                      Padding(
                                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                                        child: Text(
                                          '${'min_order_qty'.tr}: ${productController.selectedUnit!.minOrderQty}',
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],

                            /// Variation
                            (product?.variations != null && product!.variations!.isNotEmpty) ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: product!.variations!.length,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: ( product?.variations != null && product!.variations!.isNotEmpty) ? Dimensions.paddingSizeLarge : 0),
                              itemBuilder: (context, index) {
                                final variation = product!.variations![index];
                                final isRequired = variation.required ?? false;
                                final isMulti = variation.multiSelect ?? false;
                                final minSelect = variation.min ?? 0;
                                final maxSelect = variation.max ?? 0;
                                final values = variation.variationValues ?? [];
                                final int requiredMin = isMulti ? minSelect : 1;

                                bool isVarSelected(int idx, int i) {
                                  if (idx >= productController.selectedVariations.length) return false;
                                  if (i >= productController.selectedVariations[idx].length) return false;
                                  return productController.selectedVariations[idx][i] ?? false;
                                }

                                int selectedCount = 0;
                                if(isRequired){
                                  for (var value in productController.selectedVariations[index]) {
                                    if(value == true){
                                      selectedCount++;
                                    }
                                  }
                                }
                                return Container(
                                  padding: EdgeInsets.all(isRequired ? requiredMin <= selectedCount
                                      ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeSmall : 0),
                                  margin: EdgeInsets.only(bottom: index != product!.variations!.length - 1 ? Dimensions.paddingSizeDefault : 0),
                                  decoration: BoxDecoration(
                                      color: isRequired ? requiredMin <= selectedCount
                                          ? Theme.of(context).primaryColor.withValues(alpha: 0.05) :Theme.of(context).disabledColor.withValues(alpha: 0.05) : Colors.transparent,
                                      border: Border.all(color: isRequired ? requiredMin <= selectedCount
                                          ? Theme.of(context).primaryColor.withValues(alpha: 0.3) : Theme.of(context).disabledColor.withValues(alpha: 0.1) : Colors.transparent, width: 1),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                      Text(variation.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 800),
                                        curve: Curves.easeIn,
                                        decoration: BoxDecoration(
                                          color: isRequired ? requiredMin > selectedCount
                                              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        ),
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

                                        child: Text(
                                          isRequired
                                              ? requiredMin <= selectedCount ? 'completed'.tr : 'required'.tr
                                              : 'optional'.tr,
                                          style: robotoRegular.copyWith(
                                            color: isRequired
                                                ? requiredMin <= selectedCount ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.error
                                                : Theme.of(context).hintColor,
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    Row(children: [
                                      isMulti ? Text(
                                        '${'select_minimum'.tr} ${'$minSelect'
                                            ' ${'and_up_to'.tr} $maxSelect ${'options'.tr}'}',
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                                      ) : Text(
                                        'select_one'.tr,
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                                      ),
                                    ]),
                                    SizedBox(height: isMulti ? Dimensions.paddingSizeExtraSmall : 0),

                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: productController.collapseVariation[index] ? values.length > 4
                                          ? 5 : values.length : values.length,
                                      itemBuilder: (context, i) {

                                        if(i == 4 && productController.collapseVariation[index]){
                                          return Padding(
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                            child: InkWell(
                                              onTap: ()=> productController.showMoreSpecificSection(index),
                                              child: Row(children: [
                                                Icon(HeroiconsOutline.chevronDown, size: 18, color: Theme.of(context).primaryColor),
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                                Text(
                                                  '${'view'.tr} ${values.length - 4} ${'more_option'.tr}',
                                                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                                                ),
                                              ]),
                                            ),
                                          );
                                        } else{
                                          final selected = isVarSelected(index, i);
                                          final varValue = i < values.length ? values[i] : null;
                                          return Padding(
                                            padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0),
                                            child: InkWell(
                                              onTap: () {
                                                productController.setCartVariationIndex(index, i, product, isMulti);
                                                productController.setExistInCartForBottomSheet(product!, productController.selectedVariations);
                                              },
                                              child: Row(children: [
                                                Flexible(
                                                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                    isMulti ? Checkbox(
                                                      value: selected,
                                                      activeColor: Theme.of(context).primaryColor,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                                      onChanged:(bool? newValue) {
                                                        productController.setCartVariationIndex(index, i, product, isMulti);
                                                        productController.setExistInCartForBottomSheet(product!, productController.selectedVariations);
                                                      },
                                                      visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                                      side: BorderSide(width: 2, color: Theme.of(context).disabledColor),
                                                    ) : RadioGroup(
                                                      groupValue: productController.selectedVariations[index].indexOf(true),
                                                      onChanged: (dynamic value) {
                                                        productController.setCartVariationIndex(index, i, product, isMulti);
                                                        productController.setExistInCartForBottomSheet(product!, productController.selectedVariations);
                                                      },
                                                      child: Radio(
                                                        value: i,
                                                        activeColor: Theme.of(context).primaryColor,
                                                        toggleable: false,
                                                        visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                                        fillColor: WidgetStateColor.resolveWith((states) => selected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                                                      ),
                                                    ),

                                                    Flexible(
                                                      child: Text(
                                                        (varValue?.level ?? '').trim(),
                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                        style: selected ? robotoMedium : robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                                      ),
                                                    ),

                                                    Flexible(
                                                      child: (selected && (productController.quantity == (varValue?.currentStock ?? 0)))
                                                          ? Text(' (${'only'.tr} ${varValue?.currentStock ?? 0} ${'item_available'.tr})',
                                                          style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                                                      ) : Text(
                                                        ' (${'out_of_stock'.tr})',
                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                        style: (varValue?.stockType != 'unlimited' && varValue?.currentStock != null && (varValue?.currentStock ?? 0) <= 0)
                                                            ? robotoMedium.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeExtraSmall)
                                                            : robotoRegular.copyWith(color: Colors.transparent),
                                                      ),
                                                    ),

                                                  ]),
                                                ),

                                                (price > priceWithDiscount) && (discountType == 'percent') ? PriceConverter.convertPriceWithSvg(
                                                  varValue?.optionPrice,
                                                  textStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                                                  symbolColor: Theme.of(context).disabledColor,
                                                  symbolSize: 10,
                                                ) : const SizedBox(),
                                                SizedBox(width: price > priceWithDiscount ? Dimensions.paddingSizeExtraSmall : 0),

                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text('+', style: selected ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall) : robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                                    PriceConverter.convertPriceWithSvg(
                                                      varValue?.optionPrice,
                                                      discount: discount,
                                                      discountType: discountType,
                                                      isVariation: true,
                                                      textStyle: selected ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)
                                                          : robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                                      symbolColor: selected ? null : Theme.of(context).disabledColor,
                                                      symbolSize: 10,
                                                    ),
                                                  ],
                                                )
                                              ]),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ]),
                                );
                              },
                            ) : const SizedBox(),

                            SizedBox(height: (product?.variations != null && product!.variations!.isNotEmpty) ? 0 : 0),


                            (product?.addOns != null && product!.addOns!.isNotEmpty) ? Builder(
                              builder: (context) {
                                // Use local variable with null safety
                                final addOns = product?.addOns ?? [];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Text('addons'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          ),
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                          child: Text(
                                            'optional'.tr,
                                            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: addOns.length,
                                      itemBuilder: (context, index) {
                                        // Bounds check
                                        if (index >= addOns.length) return const SizedBox();
                                        final addOn = addOns[index];

                                        return InkWell(
                                          onTap: () {
                                            if (!productController.addOnActiveList[index]) {
                                              productController.addAddOn(true, index, addOn.stockType, addOn.addonStock);
                                            } else if (productController.addOnQtyList[index] == 1) {
                                              productController.addAddOn(false, index, addOn.stockType, addOn.addonStock);
                                            }
                                          },
                                          child: Row(children: [

                                            Flexible(
                                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

                                                Checkbox(
                                                  value: productController.addOnActiveList[index],
                                                  activeColor: Theme.of(context).primaryColor,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                                  onChanged:(bool? newValue) {
                                                    if (!productController.addOnActiveList[index]) {
                                                      productController.addAddOn(true, index, addOn.stockType, addOn.addonStock);
                                                    } else if (productController.addOnQtyList[index] == 1) {
                                                      productController.addAddOn(false, index, addOn.stockType, addOn.addonStock);
                                                    }
                                                  },
                                                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                                  side: BorderSide(width: 2, color: Theme.of(context).disabledColor),
                                                ),

                                                Text(
                                                  addOn.name ?? '',
                                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                                  style: productController.addOnActiveList[index] ? robotoMedium : robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                                ),

                                                Flexible(
                                                  child: Text(
                                                    ' (${'out_of_stock'.tr})',
                                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    style: addOn.stockType != 'unlimited' && addOn.addonStock != null && (addOn.addonStock ?? 0) <= 0
                                                        ? robotoMedium.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeExtraSmall)
                                                        : robotoRegular.copyWith(color: Colors.transparent),
                                                  ),
                                                ),
                                              ]),
                                            ),

                                            (addOn.price ?? 0) > 0 ? PriceConverter.convertPriceWithSvg(
                                              addOn.price,
                                              textStyle: productController.addOnActiveList[index] ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)
                                                  : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                              symbolColor: productController.addOnActiveList[index] ? null : Theme.of(context).disabledColor,
                                              symbolSize: 12,
                                            ) : Text(
                                              'free'.tr,
                                              style: productController.addOnActiveList[index] ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)
                                                  : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                            ),

                                            productController.addOnActiveList[index] ? Container(
                                              height: 25, width: 90,
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).cardColor),
                                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (productController.addOnQtyList[index]! > 1) {
                                                        productController.setAddOnQuantity(false, index, addOn.stockType, addOn.addonStock);
                                                      } else {
                                                        productController.addAddOn(false, index, addOn.stockType, addOn.addonStock);
                                                      }
                                                    },
                                                    child: Center(child: Icon(
                                                      (productController.addOnQtyList[index]! > 1) ? HeroiconsOutline.minus : HeroiconsOutline.trash, size: 18,
                                                      color: (productController.addOnQtyList[index]! > 1) ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.error,
                                                    )),
                                                  ),
                                                ),
                                                Text(
                                                  productController.addOnQtyList[index].toString(),
                                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () => productController.setAddOnQuantity(true, index, addOn.stockType, addOn.addonStock),
                                                    child: Center(child: Icon(HeroiconsOutline.plus, size: 18, color: Theme.of(context).primaryColor)),
                                                  ),
                                                ),
                                              ]),
                                            ) : const SizedBox(),

                                          ]),
                                        );

                                      },
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  ],
                                );
                              },
                            ) : const SizedBox(),

                          ]),
                        ),
                      ]),
                    ),
                  ),

                  ///Bottom side..
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusExtraLarge : 0)),
                      boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Colors.grey[300]!, blurRadius: 10)]
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),

                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('${'total_amount'.tr}:', style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Row(children: [
                              (priceWithAddonsVariation > priceWithAddonsVariationWithDiscount) ? PriceConverter.convertAnimationPrice(
                                priceWithAddonsVariation,
                                textStyle: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough),
                              ) : const SizedBox(),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              PriceConverter.convertAnimationPrice(
                                priceWithAddonsVariationWithDiscount,
                                textStyle: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                              ),

                            ]),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeSmall),


                          Row(
                            children: [
                              Row(children: [
                                QuantityButton(
                                  onTap: () {
                                    if (productController.quantity! > 1) {
                                      productController.setQuantity(false, product!.cartQuantityLimit, product!.maxQtyPerUser, product!.stockType, product!.itemStock, widget.isCampaign);
                                    }
                                  },
                                  isIncrement: false,
                                ),

                                AnimatedFlipCounter(
                                  duration: const Duration(milliseconds: 500),
                                  value: productController.quantity!.toDouble(),
                                  textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                ),

                                QuantityButton(
                                  onTap: () => productController.setQuantity(true, product!.cartQuantityLimit, product!.maxQtyPerUser, product!.stockType, product!.itemStock, widget.isCampaign),
                                  isIncrement: true,
                                ),
                              ]),

                              if(product!.maxQtyPerUser != null && product!.maxQtyPerUser! > 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    ),
                                    child: Text('${'max'.tr} ${product!.maxQtyPerUser}',
                                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)),
                                  ),
                                ),

                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(
                                child: GetBuilder<CartController>(
                                  builder: (cartController) {
                                    return CustomButtonWidget(
                                      radius : Dimensions.paddingSizeDefault,
                                      width: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.width / 2.0 : null,
                                      isLoading: cartController.isLoading,
                                      buttonText: (!widget.isCampaign && product!.stockType != null && product!.stockType != 'unlimited' && (product!.itemStock ?? 0) <= 0) ? 'out_of_stock'.tr
                                          : ((!(product!.scheduleOrder ?? false) && !isAvailable) || (widget.isCampaign && !isAvailable)) ? 'not_available_now'.tr
                                          : widget.isCampaign ? 'order_now'.tr : (widget.cart != null || productController.cartIndex != -1) ? 'update_in_cart'.tr : 'add_to_cart'.tr,
                                      onPressed: (!widget.isCampaign && product!.stockType != null && product!.stockType != 'unlimited' && (product!.itemStock ?? 0) <= 0) || ((!(product!.scheduleOrder ?? false) && !isAvailable) || (widget.isCampaign && !isAvailable)) || (widget.cart != null && productController.checkOutOfStockVariationSelected(product?.variations) != null) ? null : () async {

                                        _onButtonPressed(productController, cartController, priceWithVariation, priceWithDiscount, price, discount, discountType, addOnIdList, addOnsList, priceWithAddonsVariation);

                                      },
                                    );
                                  }
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),

                ],
              ),

              GetPlatform.isAndroid ? const SizedBox() : Positioned(
                top: 5, right: 10,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    padding:  const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 5)],
                    ),
                    child: const Icon(HeroiconsOutline.xMark, size: 14),
                  ),
                ),
              ),
            ],
          ),
        );

      }),
    );
  }

  void _onButtonPressed(
      ProductController productController, CartController cartController, double priceWithVariation, double priceWithDiscount,
      double price, double? discount, String? discountType, List<AddOn> addOnIdList, List<AddOns> addOnsList,
      double priceWithAddonsVariation,
      ) async {

    _processVariationWarning(productController);

    if(productController.canAddToCartProduct) {
      CartModel cartModel = CartModel(
        null, priceWithVariation, priceWithDiscount, (price - PriceConverter.convertWithDiscount(price, discount, discountType)!),
        productController.quantity, addOnIdList, addOnsList, widget.isCampaign, product, productController.selectedVariations,
        product!.cartQuantityLimit, productController.variationsStock,
        unitId: productController.selectedUnit?.unitId,
      );

      OnlineCart onlineCart = await _processOnlineCart(productController, cartController, addOnIdList, addOnsList, priceWithAddonsVariation);

      if(widget.isCampaign) {
        Get.find<CheckoutController>().updateFirstTime();
        Get.find<CartController>().setNeedExtraPackage(false);
        Get.back();
        Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(
          fromCart: false, cartList: [cartModel],
        ));
      }else {
        await _executeActions(cartController, productController, cartModel, onlineCart);
      }
    }
  }

  void _processVariationWarning(ProductController productController) {
    final variations = product?.variations;
    if(variations != null && variations.isNotEmpty){
      for(int index=0; index<variations.length; index++) {
        final variation = variations[index];
        final isMultiSelect = variation.multiSelect ?? false;
        final isRequired = variation.required ?? false;
        final minRequired = variation.min ?? 0;
        final maxAllowed = variation.max ?? 0;

        if(!isMultiSelect && isRequired
            && !productController.selectedVariations[index].contains(true)) {
          showCustomSnackBar('${'choose_a_variation_from'.tr} ${variation.name}');
          productController.changeCanAddToCartProduct(false);
          return;
        }else if(isMultiSelect && (isRequired
            || productController.selectedVariations[index].contains(true)) && minRequired
            > productController.selectedVariationLength(productController.selectedVariations, index)) {
          showCustomSnackBar('${'you_need_to_select_minimum'.tr} $minRequired '
              '${'to_maximum'.tr} $maxAllowed ${'options_from'.tr} ${variation.name} ${'variation'.tr}');
          productController.changeCanAddToCartProduct(false);
          return;
        } else {
          productController.changeCanAddToCartProduct(true);
        }
      }
    } else if(!widget.isCampaign && (variations == null || variations.isEmpty) && product?.stockType != null && product?.stockType != 'unlimited' && (product?.itemStock ?? 0) <= 0) {
      showCustomSnackBar('product_is_out_of_stock'.tr);
      productController.changeCanAddToCartProduct(false);
      return;
    }
  }

  Future<OnlineCart> _processOnlineCart(ProductController productController, CartController cartController, List<AddOn> addOnIdList, List<AddOns> addOnsList, double priceWithAddonsVariation) async {
    List<OrderVariation> variations = CartHelper.getSelectedVariations(
      productVariations: product?.variations, selectedVariations: productController.selectedVariations,
    ).$1;
    List<int?> optionsIdList = CartHelper.getSelectedVariations(
      productVariations: product?.variations, selectedVariations: productController.selectedVariations,
    ).$2;
    List<int?> listOfAddOnId = CartHelper.getSelectedAddonIds(addOnIdList: addOnIdList);
    List<int?> listOfAddOnQty = CartHelper.getSelectedAddonQtnList(addOnIdList: addOnIdList);

    OnlineCart onlineCart = OnlineCart(
        (widget.cart != null || productController.cartIndex != -1) ? widget.cart?.id ?? cartController.cartList[productController.cartIndex].id : null,
        widget.isCampaign ? null : product?.id, widget.isCampaign ? product?.id : null,
        priceWithAddonsVariation.toString(), variations,
        productController.quantity, listOfAddOnId, addOnsList, listOfAddOnQty, 'Food',
        variationOptionIds: optionsIdList,
        vendorId: widget.vendorId ?? (product?.supermarketId != null && product?.supermarketId != 0 ? product?.supermarketId : (product?.pharmacyId != null && product?.pharmacyId != 0 ? product?.pharmacyId : product?.restaurantId)),
        vendorType: widget.businessType ?? 'restaurant',
        unitId: productController.selectedUnit?.unitId,
    );
    return onlineCart;
  }

  Future<void> _executeActions(CartController cartController, ProductController productController, CartModel cartModel, OnlineCart onlineCart) async {
    // Check if user is logged in - if not, redirect to login screen
    if(!Get.find<AuthController>().isLoggedIn()) {
      Get.back(); // Close the product bottom sheet first
      // Delay to ensure bottom sheet is fully closed before navigating
      await Future.delayed(const Duration(milliseconds: 300));
      Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
      return;
    }

    // Single vendor at a time - show confirmation to clear cart if adding from different vendor
    // Use the appropriate vendor ID based on business type (supermarket, pharmacy, or restaurant)
    int? currentVendorId = widget.vendorId ??
        (product?.supermarketId != null && product?.supermarketId != 0 ? product?.supermarketId :
        (product?.pharmacyId != null && product?.pharmacyId != 0 ? product?.pharmacyId :
        product?.restaurantId));
    if(widget.cart != null || productController.cartIndex != -1) {
      await cartController.updateCartOnline(onlineCart, existCartData: widget.cart);
    } else if (cartController.existAnotherRestaurantProduct(currentVendorId)) {
      Get.dialog(ConfirmationDialogWidget(
        icon: Images.warning,
        title: 'are_you_sure_to_reset'.tr,
        description: 'if_you_continue'.tr,
        onYesPressed: () {
          cartController.clearCartOnline().then((success) async {
            if (success) {
              Get.back();
              await cartController.addToCartOnline(onlineCart, existCartData: widget.cart);
            }
          });
        },
      ), barrierDismissible: false);
    } else {
      await cartController.addToCartOnline(onlineCart, existCartData: widget.cart);
    }
  }

  double _getVariationPriceWithDiscount(Product product, ProductController productController, double? discount, String? discountType) {
    double variationPrice = 0;
    final variations = product.variations;
    if(variations != null && variations.isNotEmpty){
      for(int index = 0; index < variations.length; index++) {
        final variationValues = variations[index].variationValues;
        if(variationValues == null) continue;
        for(int i=0; i < variationValues.length; i++) {
          if(index < productController.selectedVariations.length && productController.selectedVariations[index].isNotEmpty && i < productController.selectedVariations[index].length && productController.selectedVariations[index][i] == true) {
            final optionPrice = variationValues[i].optionPrice ?? 0;
            variationPrice += PriceConverter.convertWithDiscount(optionPrice, discount, discountType) ?? optionPrice;
          }
        }
      }
    }
    return variationPrice;
  }

  double _getVariationPrice(Product product, ProductController productController) {
    double variationPrice = 0;
    final variations = product.variations;
    if(variations != null && variations.isNotEmpty){
      for(int index = 0; index < variations.length; index++) {
        final variationValues = variations[index].variationValues;
        if(variationValues == null) continue;
        for(int i=0; i < variationValues.length; i++) {
          if(index < productController.selectedVariations.length && productController.selectedVariations[index].isNotEmpty && i < productController.selectedVariations[index].length && productController.selectedVariations[index][i] == true) {
            final optionPrice = variationValues[i].optionPrice ?? 0;
            variationPrice += PriceConverter.convertWithDiscount(optionPrice, 0, 'none') ?? optionPrice;
          }
        }
      }
    }
    return variationPrice;
  }

  double _getAddonCost(Product product, ProductController productController) {
    double addonsCost = 0;
    final addOns = product.addOns;
    if (addOns == null || addOns.isEmpty) return addonsCost;

    for (int index = 0; index < addOns.length; index++) {
      if (index < productController.addOnActiveList.length && productController.addOnActiveList[index]) {
        final price = addOns[index].price ?? 0;
        final qty = index < productController.addOnQtyList.length ? (productController.addOnQtyList[index] ?? 1) : 1;
        addonsCost = addonsCost + (price * qty);
      }
    }

    return addonsCost;
  }

  List<AddOn> _getAddonIdList(Product product, ProductController productController) {
    List<AddOn> addOnIdList = [];
    final addOns = product.addOns;
    if (addOns == null || addOns.isEmpty) return addOnIdList;

    for (int index = 0; index < addOns.length; index++) {
      if (index < productController.addOnActiveList.length && productController.addOnActiveList[index]) {
        addOnIdList.add(AddOn(id: addOns[index].id, quantity: index < productController.addOnQtyList.length ? productController.addOnQtyList[index] : 1));
      }
    }

    return addOnIdList;
  }

  List<AddOns> _getAddonList(Product product, ProductController productController) {
    List<AddOns> addOnsList = [];
    final addOns = product.addOns;
    if (addOns == null || addOns.isEmpty) return addOnsList;

    for (int index = 0; index < addOns.length; index++) {
      if (index < productController.addOnActiveList.length && productController.addOnActiveList[index]) {
        addOnsList.add(addOns[index]);
      }
    }

    return addOnsList;
  }

  /// Build pharmacy details section for pharmacy products
  Widget _buildPharmacyDetailsSection(BuildContext context, Product product) {
    // Check if any pharmacy data exists
    bool hasPharmacyData = product.genericName != null ||
        product.activeIngredient != null ||
        product.dosageForm != null ||
        product.strength != null ||
        product.manufacturer != null ||
        product.brand != null ||
        product.routeOfAdministration != null ||
        product.storageConditions != null ||
        product.sideEffects != null ||
        product.contraindications != null ||
        product.drugInteractions != null ||
        product.maxDailyDose != null ||
        product.pregnancyCategory != null ||
        product.lactationSafety != null ||
        product.ageRestriction != null ||
        product.packageSize != null ||
        product.unit != null ||
        product.prescriptionRequired == true;

    if (!hasPharmacyData) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prescription Required Badge
        if (product.prescriptionRequired == true) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(HeroiconsOutline.buildingOffice, size: 16, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  'prescription_required'.tr,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],

        // Medicine Information Section
        if (product.genericName != null ||
            product.activeIngredient != null ||
            product.dosageForm != null ||
            product.strength != null ||
            product.therapeuticCategory != null) ...[
          _buildPharmacySectionHeader(context, 'medicine_information'.tr, HeroiconsOutline.beaker),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildPharmacyInfoCard(context, [
            if (product.genericName != null) _PharmacyInfoItem('generic_name'.tr, product.genericName!),
            if (product.activeIngredient != null) _PharmacyInfoItem('active_ingredient'.tr, product.activeIngredient!),
            if (product.dosageForm != null) _PharmacyInfoItem('dosage_form'.tr, product.dosageForm!),
            if (product.strength != null) _PharmacyInfoItem('strength'.tr, product.strength!),
            if (product.therapeuticCategory != null) _PharmacyInfoItem('therapeutic_category'.tr, product.therapeuticCategory!),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],

        // Usage & Safety Section
        if (product.routeOfAdministration != null ||
            product.storageConditions != null ||
            product.maxDailyDose != null) ...[
          _buildPharmacySectionHeader(context, 'usage_and_safety'.tr, HeroiconsOutline.shieldCheck),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildPharmacyInfoCard(context, [
            if (product.routeOfAdministration != null) _PharmacyInfoItem('route_of_administration'.tr, product.routeOfAdministration!),
            if (product.storageConditions != null) _PharmacyInfoItem('storage_conditions'.tr, product.storageConditions!),
            if (product.maxDailyDose != null) _PharmacyInfoItem('max_daily_dose'.tr, product.maxDailyDose!),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],

        // Warnings Section
        if (product.sideEffects != null ||
            product.contraindications != null ||
            product.drugInteractions != null ||
            product.pregnancyCategory != null ||
            product.lactationSafety != null ||
            product.ageRestriction != null) ...[
          _buildPharmacySectionHeader(context, 'warnings'.tr, HeroiconsOutline.exclamationTriangle),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildPharmacyInfoCard(context, [
            if (product.sideEffects != null) _PharmacyInfoItem('side_effects'.tr, product.sideEffects!),
            if (product.contraindications != null) _PharmacyInfoItem('contraindications'.tr, product.contraindications!),
            if (product.drugInteractions != null) _PharmacyInfoItem('drug_interactions'.tr, product.drugInteractions!),
            if (product.pregnancyCategory != null) _PharmacyInfoItem('pregnancy_category'.tr, product.pregnancyCategory!),
            if (product.lactationSafety != null) _PharmacyInfoItem('lactation_safety'.tr, product.lactationSafety!),
            if (product.ageRestriction != null) _PharmacyInfoItem('age_restriction'.tr, product.ageRestriction!),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],

        // Packaging & Manufacturer Section
        if (product.manufacturer != null ||
            product.brand != null ||
            product.packageSize != null ||
            product.unit != null) ...[
          _buildPharmacySectionHeader(context, 'packaging_info'.tr, HeroiconsOutline.archiveBox),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildPharmacyInfoCard(context, [
            if (product.manufacturer != null) _PharmacyInfoItem('manufacturer'.tr, product.manufacturer!),
            if (product.brand != null) _PharmacyInfoItem('brand'.tr, product.brand!),
            if (product.packageSize != null) _PharmacyInfoItem('package_size'.tr, product.packageSize!),
            if (product.unit != null) _PharmacyInfoItem('unit'.tr, product.unit!),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ],
    );
  }

  Widget _buildPharmacySectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      ],
    );
  }

  Widget _buildPharmacyInfoCard(BuildContext context, List<_PharmacyInfoItem> items) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    '${item.label}:',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.value,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

}

class _PharmacyInfoItem {
  final String label;
  final String value;

  _PharmacyInfoItem(this.label, this.value);
}

