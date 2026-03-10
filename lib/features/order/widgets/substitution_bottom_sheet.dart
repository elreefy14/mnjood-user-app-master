import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/order/domain/models/substitution_proposal_model.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class SubstitutionBottomSheet extends StatelessWidget {
  final int orderId;
  const SubstitutionBottomSheet({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      final proposals = orderController.substitutionProposals ?? [];
      final pendingProposals = proposals.where((p) => p.status == 'pending').toList();

      return Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Row(children: [
              Icon(HeroiconsOutline.arrowsRightLeft, color: Theme.of(context).primaryColor, size: 22),
              const SizedBox(width: 8),
              Text('substitution_available'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const Spacer(),
              InkWell(
                onTap: () => Get.back(),
                child: Icon(HeroiconsOutline.xMark, size: 24, color: Theme.of(context).disabledColor),
              ),
            ]),
          ),

          const Divider(height: 1),

          // Proposals list
          if (orderController.isSubstitutionLoading)
            const Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (pendingProposals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(children: [
                Icon(HeroiconsOutline.checkCircle, size: 48, color: Colors.green),
                const SizedBox(height: 8),
                Text('All substitutions have been reviewed', style: robotoMedium),
              ]),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pendingProposals.length,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                itemBuilder: (context, index) {
                  return _SubstitutionCard(
                    proposal: pendingProposals[index],
                    orderId: orderId,
                  );
                },
              ),
            ),
        ]),
      );
    });
  }
}

class _SubstitutionCard extends StatelessWidget {
  final SubstitutionProposal proposal;
  final int orderId;

  const _SubstitutionCard({required this.proposal, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Original vs Proposed
        Row(children: [
          // Original item
          Expanded(child: _ItemColumn(
            label: 'original_item'.tr,
            item: proposal.originalItem,
            labelColor: Colors.red.shade100,
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(HeroiconsOutline.arrowRight, size: 20, color: Theme.of(context).disabledColor),
          ),
          // Proposed item
          Expanded(child: _ItemColumn(
            label: 'proposed_item'.tr,
            item: proposal.proposedItem,
            labelColor: Colors.green.shade100,
          )),
        ]),

        // Price difference
        if (proposal.priceDifference != null && proposal.priceDifference != 0) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (proposal.priceDifference! > 0 ? Colors.orange : Colors.green).withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${'price_difference'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
              Text(
                '${proposal.priceDifference! > 0 ? '+' : ''}${PriceConverter.convertPrice(proposal.priceDifference)}',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: proposal.priceDifference! > 0 ? Colors.orange : Colors.green,
                ),
              ),
            ]),
          ),
        ],

        // Store note
        if (proposal.storeNote != null && proposal.storeNote!.isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Icon(HeroiconsOutline.chatBubbleBottomCenterText, size: 14, color: Theme.of(context).disabledColor),
            const SizedBox(width: 4),
            Text('${'store_note'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
            Flexible(child: Text(proposal.storeNote!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall))),
          ]),
        ],

        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Accept / Reject buttons
        GetBuilder<OrderController>(builder: (controller) {
          return Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.isSubstitutionLoading ? null : () {
                  controller.respondToSubstitution(proposal.id!, 'reject').then((success) {
                    if (success) {
                      showCustomSnackBar('substitution_rejected'.tr, isError: false);
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                ),
                child: Text('reject_substitution'.tr),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.isSubstitutionLoading ? null : () {
                  controller.respondToSubstitution(proposal.id!, 'accept').then((success) {
                    if (success) {
                      showCustomSnackBar('substitution_accepted'.tr, isError: false);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                ),
                child: Text('accept_substitution'.tr),
              ),
            ),
          ]);
        }),
      ]),
    );
  }
}

class _ItemColumn extends StatelessWidget {
  final String label;
  final SubstitutionItem? item;
  final Color labelColor;

  const _ItemColumn({required this.label, required this.item, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: labelColor, borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
      ),
      const SizedBox(height: 8),
      if (item?.image != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: CustomImageWidget(image: item!.image!, height: 50, width: 50, fit: BoxFit.cover),
        ),
      const SizedBox(height: 4),
      Text(item?.name ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
      if (item?.price != null)
        PriceConverter.convertPriceWithSvg(item!.price!, textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
    ]);
  }
}

void showSubstitutionBottomSheet({required int orderId}) {
  Get.find<OrderController>().getSubstitutionProposals(orderId);
  Get.bottomSheet(
    SubstitutionBottomSheet(orderId: orderId),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
