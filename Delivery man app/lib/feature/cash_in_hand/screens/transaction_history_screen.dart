import 'package:mnjood_delivery/feature/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:mnjood_delivery/helper/price_converter_helper.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:mnjood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {

  @override
  void initState() {
    super.initState();
    
    Get.find<CashInHandController>().getWalletPaymentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: CustomAppBarWidget(title: 'transaction_history'.tr),

      body: GetBuilder<CashInHandController>(builder: (cashInHandController) {
        return cashInHandController.transactions != null ? cashInHandController.transactions!.isNotEmpty ? ListView.builder(
          itemCount: cashInHandController.transactions!.length,
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(children: [

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                child: Row(children: [

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      PriceConverter.convertPriceWithSvg(cashInHandController.transactions![index].amount, textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text(
                        '${'paid_via'.tr} ${cashInHandController.transactions![index].method?.replaceAll('_', ' ').capitalize??''}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                      ),

                    ]),
                  ),

                  Text(
                    cashInHandController.transactions![index].paymentTime.toString(),
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),

                ]),
              ),

              const Divider(height: 1),

            ]);
          },
        ) : Center(child: Text('no_transaction_found'.tr)) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}