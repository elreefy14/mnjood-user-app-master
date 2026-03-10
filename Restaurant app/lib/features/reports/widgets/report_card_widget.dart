import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_card.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class ReportCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final Function onTap;
  const ReportCardWidget({super.key, required this.title, required this.subtitle, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: CustomCard(
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: CustomAssetImageWidget(
              image: image, height: 50, width: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault)),
            ),
            child: Row(children: [

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall - 2),

                  Text(subtitle, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),

                ]),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1, spreadRadius: 0)],
                ),
                child: Icon(HeroiconsOutline.arrowRight, size: 20, color: Theme.of(context).primaryColor),
              ),

            ]),
          ),

        ]),
      ),
    );
  }
}
