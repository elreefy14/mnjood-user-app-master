import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/language/domain/models/language_model.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class LanguageCardWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  final bool fromBottomSheet;
  final bool fromWeb;
  const LanguageCardWidget({super.key, required this.languageModel, required this.localizationController, required this.index, this.fromBottomSheet = false, this.fromWeb = false});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellWidget(
      onTap: () {
        if(fromBottomSheet){
          localizationController.setLanguage(Locale(
            AppConstants.languages[index].languageCode!,
            AppConstants.languages[index].countryCode,
          ), fromBottomSheet: fromBottomSheet);
        }
        localizationController.setSelectLanguageIndex(index);
      },
      radius: Dimensions.radiusLarge,
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: !fromWeb ? BoxDecoration(
          color: localizationController.selectedLanguageIndex == index ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : null,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: localizationController.selectedLanguageIndex == index ? Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)) : null,
        ) : BoxDecoration(
          color: localizationController.selectedLanguageIndex == index ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: localizationController.selectedLanguageIndex == index ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Theme.of(context).disabledColor.withValues(alpha: 0.3)),
        ),
        child: Row(children: [

          SizedBox(
            width: 36, height: 36,
            child: Center(
              child: languageModel.imageUrl!.endsWith('.svg')
                ? SvgPicture.asset(languageModel.imageUrl!, width: 36, height: 24, fit: BoxFit.contain)
                : Image.asset(languageModel.imageUrl!, width: 36, height: 36),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Text(languageModel.languageName!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const Spacer(),

          localizationController.selectedLanguageIndex == index ? Icon(HeroiconsOutline.checkCircle, color: Theme.of(context).primaryColor, size: 25) : const SizedBox(),

        ]),
      ),
    );
  }
}