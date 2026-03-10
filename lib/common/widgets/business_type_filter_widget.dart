import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/enums/business_type_enum.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/business_type_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class BusinessTypeFilterWidget extends StatelessWidget {
  const BusinessTypeFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(
      builder: (restaurantController) {
        return Container(
          height: 45,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: BusinessTypeHelper.getAllTypes().length,
            separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeSmall),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            itemBuilder: (context, index) {
              BusinessType type = BusinessTypeHelper.getAllTypes()[index];
              bool isSelected = restaurantController.businessType == type.name;

              return InkWell(
                onTap: () {
                  restaurantController.setBusinessType(type.name);
                },
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        BusinessTypeHelper.getIcon(type),
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : BusinessTypeHelper.getColor(type),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type.displayName,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
