import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final IconData? icon;
  final IconData? activeIcon;
  final String? imagePath;
  final String label;
  final Function? onTap;
  final bool isSelected;
  final bool showBadge;

  const BottomNavItemWidget({
    super.key,
    this.icon,
    this.activeIcon,
    this.imagePath,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              imagePath!,
                              width: 36,
                              height: 36,
                            ),
                          )
                        : Icon(
                            isSelected ? activeIcon : icon,
                            size: 24,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).hintColor,
                          ),
                  ),

                  // Badge for order requests
                  if (showBadge)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GetBuilder<OrderController>(builder: (orderController) {
                        int count = orderController.latestOrderList?.length ?? 0;
                        if (count == 0) return const SizedBox();
                        return Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: (isSelected ? robotoMedium : robotoRegular).copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).hintColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
