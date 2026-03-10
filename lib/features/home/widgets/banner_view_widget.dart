import 'package:carousel_slider/carousel_slider.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerViewWidget extends StatelessWidget {
  const BannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<HomeController>(builder: (homeController) {
      // Use sliders from the new API
      final sliders = homeController.sliderList;

      return (sliders != null && sliders.isEmpty) ? const SizedBox() : Container(
        width: MediaQuery.of(context).size.width,
        height: GetPlatform.isDesktop ? 500 : 205,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: sliders != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                aspectRatio: 2.5,
                enlargeFactor: 0.3,
                autoPlay: true,
                enlargeCenterPage: true,
                disableCenter: true,
                autoPlayInterval: const Duration(seconds: 5),
                onPageChanged: (index, reason) {
                  homeController.setSliderIndex(index, true);
                },
              ),
              itemCount: sliders.isEmpty ? 1 : sliders.length,
              itemBuilder: (context, index, _) {
                final slider = sliders[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), spreadRadius: 0, blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomImageWidget(
                      image: slider.imageFullUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),

          ],
        ) : Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Shimmer(
              child: Container(decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).shadowColor,
              )),
            ),
          ),
        ),
      );
    });
  }

}
