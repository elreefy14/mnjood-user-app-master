import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TipsWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  final bool isSuggested;
  final int index;
  const TipsWidget({super.key, required this.title, required this.isSelected, required this.onTap, required this.isSuggested, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeExtraSmall, bottom: 0),
      child: Column(children: [

        InkWell(
          onTap: onTap as void Function()?,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: (index == 0 || index == AppConstants.tips.length -1) ? 6 : 5, horizontal: Dimensions.paddingSizeDefault),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3), width: isSelected ? 0 : 1),
              boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))] : [],
            ),
            child: Column(children: [
              Text(
                title, textDirection: TextDirection.ltr,
                style: robotoMedium.copyWith(
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color!,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        isSuggested ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'most_tipped'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: 10),
          ),
        ) : const SizedBox(),
      ]),
    );
  }
}
