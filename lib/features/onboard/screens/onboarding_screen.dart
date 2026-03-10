import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/onboard/controllers/onboard_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/helper/address_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({super.key});
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    Get.find<OnBoardingController>().getOnBoardingList();
    return GetBuilder<OnBoardingController>(builder: (onBoardingController) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: onBoardingController.onBoardingList != null ? Stack(
          children: [
            // Curved red background at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.45),
                painter: CurvedBackgroundPainter(color: const Color(0xFFD32F2F)),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar with skip button and logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button
                        onBoardingController.selectedIndex == 2 ? const SizedBox(width: 50) : InkWell(
                          onTap: () => _configureToRouteInitialPage(),
                          child: Text(
                            'skip'.tr,
                            style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                          ),
                        ),
                        // Logo
                        Image.asset(
                          Images.logo,
                          height: 50,
                          width: 50,
                        ),
                        const SizedBox(width: 50),
                      ],
                    ),
                  ),

                  // PageView for onboarding content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onBoardingController.onBoardingList!.length,
                      onPageChanged: (index) {
                        onBoardingController.changeSelectIndex(index);
                      },
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            // Image
                            Expanded(
                              flex: index == 2 ? 2 : 5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                child: Image.asset(
                                  onBoardingController.onBoardingList![index].imageUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            // Title and description or location buttons
                            Expanded(
                              flex: index == 2 ? 4 : 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      onBoardingController.onBoardingList![index].title,
                                      style: robotoBold.copyWith(
                                        fontSize: index == 2 ? 22 : 26,
                                        color: const Color(0xFFDA281C),
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFFFF9E1B),
                                            offset: const Offset(0, 4),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: index == 2 ? 8 : Dimensions.paddingSizeDefault),
                                    // Show location buttons on 3rd screen, description on others
                                    if (index == 2) ...[
                                      // Short description
                                      Text(
                                        onBoardingController.onBoardingList![index].description,
                                        style: robotoRegular.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xFF333333),
                                          height: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      // Select on map button
                                      InkWell(
                                        onTap: () => _useCurrentLocation(),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDA281C),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(HeroiconsOutline.map, color: Colors.white, size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                'select_location_on_map'.tr,
                                                style: robotoBold.copyWith(color: Colors.white, fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      // Enter location button
                                      InkWell(
                                        onTap: () => _searchLocation(),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFDA281C), width: 2),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(HeroiconsOutline.mapPin, color: Color(0xFFDA281C), size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                'enter_your_location'.tr,
                                                style: robotoBold.copyWith(color: const Color(0xFFDA281C), fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ] else
                                      Text(
                                        onBoardingController.onBoardingList![index].description,
                                        style: robotoRegular.copyWith(
                                          fontSize: 18,
                                          color: const Color(0xFF333333),
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Bottom section with navigation button and indicators (hidden on 3rd screen)
                  if (onBoardingController.selectedIndex != 2)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraLarge),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Empty space on start side
                          const SizedBox(width: 56),

                          // Page indicators in center
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _pageIndicators(onBoardingController, context),
                          ),

                          // Navigation button on end side (right in LTR, left in RTL)
                          InkWell(
                            onTap: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                            child: Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDA281C),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFF9E1B),
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Directionality.of(context) == TextDirection.rtl
                                    ? HeroiconsOutline.arrowLeft
                                    : HeroiconsOutline.arrowRight,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ) : const Center(child: CircularProgressIndicator()),
      );
    });
  }

  List<Widget> _pageIndicators(OnBoardingController onBoardingController, BuildContext context) {
    List<Container> indicators = [];
    for (int i = 0; i < onBoardingController.onBoardingList!.length; i++) {
      indicators.add(
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == onBoardingController.selectedIndex
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ),
        ),
      );
    }
    return indicators;
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<SplashController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  void _useCurrentLocation() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    Get.find<SplashController>().navigateToLocationScreen('splash', offNamed: true);
  }

  void _searchLocation() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    Get.find<SplashController>().navigateToLocationScreen('splash', offNamed: true);
  }
}

// Custom painter for curved red background
class CurvedBackgroundPainter extends CustomPainter {
  final Color color;

  CurvedBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.1,
      size.width,
      size.height * 0.75,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
