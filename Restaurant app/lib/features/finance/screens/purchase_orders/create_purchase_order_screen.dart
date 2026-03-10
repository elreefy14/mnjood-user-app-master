import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class CreatePurchaseOrderScreen extends StatelessWidget {
  const CreatePurchaseOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'create_purchase_order'.tr),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                HeroiconsOutline.shoppingCart,
                size: 80,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(
                'coming_soon'.tr,
                style: robotoBold.copyWith(fontSize: 18),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'purchase_order_creation_coming_soon'.tr,
                style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
