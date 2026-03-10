import 'package:mnjood_delivery/common/widgets/custom_image_widget.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_details_model.dart';
import 'package:mnjood_delivery/helper/price_converter_helper.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';

class ProductWidget extends StatelessWidget {
  final OrderDetailsModel orderDetailsModel;
  const ProductWidget({super.key, required this.orderDetailsModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(children: [

        ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), child: CustomImageWidget(
          image: '${orderDetailsModel.foodDetails!.imageFullUrl}',
          height: 50, width: 50, fit: BoxFit.cover,
        )),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

        Text('✕ ${orderDetailsModel.quantity}'),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(child: Text(
          orderDetailsModel.foodDetails!.name!, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        )),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        PriceConverter.convertPriceWithSvg(orderDetailsModel.price!-orderDetailsModel.discountOnFood!, textStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        ),

      ]),
    );
  }
}