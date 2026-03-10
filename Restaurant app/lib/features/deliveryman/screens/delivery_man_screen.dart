import 'package:mnjood_vendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_card.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/features/deliveryman/controllers/deliveryman_controller.dart';
import 'package:mnjood_vendor/features/deliveryman/domain/models/delivery_man_model.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class DeliveryManScreen extends StatelessWidget {
  const DeliveryManScreen({super.key});

  @override
  Widget build(BuildContext context) {

    Get.find<DeliveryManController>().getDeliveryManList();

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,

      appBar: CustomAppBarWidget(title: 'delivery_man'.tr),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getAddDeliveryManRoute(null)),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(HeroiconsOutline.plus, color: Theme.of(context).cardColor, size: 30),
      ),

      body: GetBuilder<DeliveryManController>(builder: (dmController) {
        return dmController.deliveryManList != null ? dmController.deliveryManList!.isNotEmpty ? ListView.builder(
          itemCount: dmController.deliveryManList!.length,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          itemBuilder: (context, index) {

            DeliveryManModel deliveryMan = dmController.deliveryManList![index];

            return CustomCard(
              padding: EdgeInsets.only(
                left: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall,
              ),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getDeliveryManDetailsRoute(deliveryMan)),
                child: Column(children: [

                  Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: deliveryMan.active == 1 ? Colors.green : Theme.of(context).colorScheme.error, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(child: CustomImageWidget(
                        image: '${deliveryMan.imageFullUrl}',
                        height: 50, width: 50, fit: BoxFit.cover,
                      )),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Text(
                      '${deliveryMan.fName} ${deliveryMan.lName}', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: robotoMedium,
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    IconButton(
                      onPressed: () => Get.toNamed(RouteHelper.getAddDeliveryManRoute(deliveryMan)),
                      icon: const Icon(HeroiconsOutline.pencilSquare, color: Colors.blue),
                    ),

                    IconButton(
                      onPressed: () {
                        Get.dialog(ConfirmationDialogWidget(
                          icon: HeroiconsOutline.exclamationTriangle, description: 'are_you_sure_want_to_delete_this_delivery_man'.tr,
                          onYesPressed: () => Get.find<DeliveryManController>().deleteDeliveryMan(deliveryMan.id!),
                        ));
                      },
                      icon: Icon(HeroiconsOutline.trash, color: Theme.of(context).colorScheme.error),
                    ),

                  ]),

                ]),
              ),
            );
          },
        ) : Center(child: Text('no_delivery_man_found'.tr)) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}