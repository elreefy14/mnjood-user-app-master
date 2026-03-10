import 'package:mnjood/features/wallet/domain/models/wallet_model.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryCartWidget extends StatelessWidget {
  final int index;
  final List<Transaction>? data;
  const HistoryCartWidget({super.key, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    final transaction = data![index];
    final type = transaction.transactionType ?? '';
    bool isDebit = (type == 'order_place' || type == 'partial_payment');

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [

              isDebit
                  ? Image.asset(Images.debitIconWallet, height: 15, width: 15)
                  : Image.asset(Images.creditIconWallet, height: 15, width: 15),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text(isDebit ? '- ' : '+ ',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              PriceConverter.convertPriceWithSvg(
                isDebit
                    ? (transaction.debit ?? 0) + (transaction.adminBonus ?? 0)
                    : (transaction.credit ?? 0) + (transaction.adminBonus ?? 0),
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                symbolSize: 12,
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              type == 'add_fund' ? '${'added_via'.tr} ${(transaction.reference ?? '').replaceAll('_', ' ')} ${(transaction.adminBonus ?? 0) != 0 ? '(${'bonus'.tr} = ${transaction.adminBonus})' : '' }'
                  : type == 'partial_payment' ? '${'spend_on_order'.tr} # ${transaction.reference ?? ''}'
                  : type == 'loyalty_point' ? 'converted_from_loyalty_point'.tr
                  : type == 'referrer' ? 'earned_by_referral'.tr
                  : type == 'order_place' ? '${'order_place'.tr} # ${transaction.reference ?? ''}'
                  : type.isNotEmpty ? type.tr : 'wallet_transaction'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).hintColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ])),

          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              transaction.createdAt != null ? DateConverter.onlyDate(transaction.createdAt!) : '',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).hintColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              isDebit ? 'debit'.tr : 'credit'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: isDebit
                  ? Colors.red : Colors.green),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ]),

        ]),

      index == data!.length-1 ? const SizedBox() : Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Divider(color: Theme.of(context).disabledColor),
      ),

    ]);
  }
}
