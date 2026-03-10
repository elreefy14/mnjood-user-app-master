import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/home/controllers/advertisement_controller.dart';
import 'package:mnjood/features/home/domain/models/advertisement_model.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/restaurant/screens/restaurant_screen.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:video_player/video_player.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class HighlightWidgetView extends StatefulWidget {
  final String? businessType;
  const HighlightWidgetView({super.key, this.businessType});

  @override
  State<HighlightWidgetView> createState() => _HighlightWidgetViewState();
}

class _HighlightWidgetViewState extends State<HighlightWidgetView> {

  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    // Load advertisement data for the specific business type
    if (widget.businessType != null) {
      Get.find<AdvertisementController>().getAdvertisementList(businessType: widget.businessType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      // Use businessType-specific list if provided, otherwise use default list
      final adList = widget.businessType != null
          ? advertisementController.getAdvertisementListByType(widget.businessType)
          : advertisementController.advertisementList;

      return adList != null && adList.isNotEmpty ? Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
        child: Stack(
          children: [

            CustomAssetImageWidget(
              Images.highlightBg, width: context.width,
              fit: BoxFit.cover,
            ),

            Column(children: [

              Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('highlights_for_you'.tr, style: sectionTitleStyle),
                      const SizedBox(width: 5),

                      Text('see_our_most_popular_restaurant_and_foods'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                    ],
                  ),

                  const CustomAssetImageWidget(
                    Images.highlightIcon, height: 50, width: 50,
                  ),

                ]),
              ),

              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: adList.length,
                options: CarouselOptions(
                  enableInfiniteScroll: adList.length > 2,
                  autoPlay: advertisementController.autoPlay,
                  enlargeCenterPage: false,
                  height: 280,
                  viewportFraction: 1,
                  disableCenter: true,
                  onPageChanged: (index, reason) {

                    advertisementController.setCurrentIndex(index, true);

                    if(adList[index].addType == "video_promotion"){
                      advertisementController.updateAutoPlayStatus(status: false);
                    }else{
                      advertisementController.updateAutoPlayStatus(status: true);
                    }

                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return adList[index].addType == 'video_promotion' ? HighlightVideoWidget(
                    advertisement: adList[index],
                  ) : HighlightRestaurantWidget(advertisement: adList[index]);
                },
              ),

              AdvertisementIndicator(businessType: widget.businessType),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

            ]),
          ],
        ),
      ) : adList == null ? const AdvertisementShimmer() : const SizedBox();
    });
  }
}

class HighlightRestaurantWidget extends StatelessWidget {
  final AdvertisementModel advertisement;
  const HighlightRestaurantWidget({super.key, required this.advertisement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.07), width: 2),
      ),
      child: InkWell(
        onTap: (){
          if (advertisement.restaurantId == null) return;
          Get.toNamed(RouteHelper.getRestaurantRoute(advertisement.restaurantId),
            arguments: RestaurantScreen(restaurant: Restaurant(id: advertisement.restaurantId)),
          );
        },
        child: Column(children: [

          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
              child: Stack(
                children: [
                  CustomImageWidget(
                    image: advertisement.coverImageFullUrl ?? '',
                    fit: BoxFit.cover, height: 160, width: double.infinity,
                  ),

                  (advertisement.isRatingActive == 1 || advertisement.isReviewActive == 1) ? Positioned(
                    right: 10, bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Theme.of(context).cardColor, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 0)],
                      ),
                      child: Row(
                        children: [
                          advertisement.isRatingActive == 1 ? Icon(HeroiconsSolid.star, color: Theme.of(context).cardColor, size: 15) : const SizedBox(),
                          SizedBox(width: advertisement.isRatingActive == 1 ? 5 : 0),

                          advertisement.isRatingActive == 1 ? Text('${advertisement.averageRating?.toStringAsFixed(1)}', style: robotoBold.copyWith(color: Theme.of(context).cardColor)) : const SizedBox(),
                          SizedBox(width: advertisement.isRatingActive == 1 ? 5 : 0),

                          advertisement.isReviewActive == 1 ? Text('(${advertisement.reviewsCommentsCount})', style: robotoRegular.copyWith(color: Theme.of(context).cardColor)) : const SizedBox(),
                        ],
                      ),
                    ),
                  ) : const SizedBox(),

                ],
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 2),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      image: advertisement.profileImageFullUrl ?? '',
                      height: 60, width: 60, fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Flexible(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      Flexible(
                        child: Text(
                          advertisement.title ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis
                        ),
                      ),

                      GetBuilder<FavouriteController>(builder: (favouriteController) {
                        bool isWished = favouriteController.wishRestIdList.contains(advertisement.restaurantId);
                        return CustomFavouriteWidget(
                          isWished: isWished,
                          isRestaurant: true,
                          restaurantId: advertisement.restaurantId,
                        );
                      }),

                    ]),
                    const SizedBox(height: 3),

                    Text(
                      advertisement.description ?? '',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),

                  ]),
                ),


              ]),
            ),
          ),

        ]),
      ),
    );
  }
}

class HighlightVideoWidget extends StatefulWidget {
  final AdvertisementModel advertisement;
  const HighlightVideoWidget({super.key, required this.advertisement});

  @override
  State<HighlightVideoWidget> createState() => _HighlightVideoWidgetState();
}

class _HighlightVideoWidgetState extends State<HighlightVideoWidget> {

  VideoPlayerController? videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    final videoUrl = widget.advertisement.videoAttachmentFullUrl;

    // Don't try to initialize if URL is empty or null
    if (videoUrl == null || videoUrl.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    try {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await videoPlayerController!.initialize();

      videoPlayerController!.addListener(() {
        if(videoPlayerController!.value.duration == videoPlayerController!.value.position){
          if(GetPlatform.isWeb){
            Future.delayed(const Duration(seconds: 4), () {
              Get.find<AdvertisementController>().updateAutoPlayStatus(status: true, shouldUpdate: true);
            });
          }else{
            Get.find<AdvertisementController>().updateAutoPlayStatus(status: true, shouldUpdate: true);
          }
        }
      });

      _createChewieController();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() {});
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _createChewieController() {
    if (videoPlayerController == null) return;
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      aspectRatio: videoPlayerController!.value.aspectRatio,
    );
    _chewieController?.setVolume(0);
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.07), width: 2),
        ),
        child: Column(children: [

          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
              child: Stack(
                children: [
                  _hasError ? Container(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(HeroiconsOutline.videoCameraSlash, size: 40, color: Theme.of(context).disabledColor),
                          const SizedBox(height: 8),
                          Text('video_unavailable'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                        ],
                      ),
                    ),
                  ) : _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized ? Stack(
                    children: [
                      Chewie(controller: _chewieController!),
                    ],
                  ) : const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  widget.advertisement.title ?? '',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Expanded(
                    child: Text(
                      widget.advertisement.description ?? '',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  InkWell(
                    onTap: (){
                      if (widget.advertisement.restaurantId == null) return;
                      Get.toNamed(RouteHelper.getRestaurantRoute(widget.advertisement.restaurantId),
                        arguments: RestaurantScreen(restaurant: Restaurant(id: widget.advertisement.restaurantId)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Icon(HeroiconsOutline.arrowRight, color: Theme.of(context).cardColor, size: 20),
                    ),
                  ),

                ]),

              ]),
            ),
          ),

        ]),
      );
    });
  }
}

class AdvertisementIndicator extends StatelessWidget {
  final String? businessType;
  const AdvertisementIndicator({super.key, this.businessType});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      // Use businessType-specific list if provided, otherwise use default list
      final adList = businessType != null
          ? advertisementController.getAdvertisementListByType(businessType)
          : advertisementController.advertisementList;

      return adList != null && adList.length > 2 ?
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(height: 7, width: 7,
          decoration:  BoxDecoration(color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: adList.map((advertisement) {
            int index = adList.indexOf(advertisement);
            return index == advertisementController.currentIndex ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 3),
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                  color:  Theme.of(context).primaryColor ,
                  borderRadius: BorderRadius.circular(50)),
              child:  Text("${index+1}/ ${adList.length}",
                style: const TextStyle(color: Colors.white,fontSize: 12),),
            ):const SizedBox();
          }).toList(),
        ),
        Container(
          height: 7, width: 7,
          decoration:  BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ]): adList != null && adList.length == 2 ?
      Align(
        alignment: Alignment.center,
        child: AnimatedSmoothIndicator(
          activeIndex: advertisementController.currentIndex,
          count: adList.length,
          effect: ExpandingDotsEffect(
            dotHeight: 7,
            dotWidth: 7,
            spacing: 5,
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotColor: Theme.of(context).hintColor.withValues(alpha: 0.6),
          ),
        ),
      ): const SizedBox();
    });
  }
}

class AdvertisementShimmer extends StatelessWidget {
  const AdvertisementShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        ),
        margin:  EdgeInsets.only(
          top: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge * 3.5 : 0 ,
          right: Get.find<LocalizationController>().isLtr && ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0,
          left: !Get.find<LocalizationController>().isLtr && ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0,
        ),
        child: Padding( padding : const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: Dimensions.paddingSizeLarge,),

              Container(height: 20, width: 200,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).shadowColor
                ),),

              const SizedBox(height: Dimensions.paddingSizeSmall,),

              Container(height: 15, width: 250,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).shadowColor,
                ),),

              const SizedBox(height: Dimensions.paddingSizeDefault * 2,),

              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: ResponsiveHelper.isDesktop(context) ? 3 : 1,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: ResponsiveHelper.isDesktop(context) ? (Dimensions.webMaxWidth - 20) / 3 : MediaQuery.of(context).size.width,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(padding: const EdgeInsets.only(bottom: 0, left: 10, right: 10),
                            child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                color: Theme.of(context).shadowColor,
                                border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2),),
                              ),
                              padding: const EdgeInsets.only(bottom: 25),
                              child: const Center(child: Icon(HeroiconsOutline.playCircle, color: Colors.white,size: 45,),),
                            ),
                          ),

                          Positioned( bottom: 0, left: 0,right: 0, child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                color: Theme.of(context).cardColor,
                                border: Border.all(color: Theme.of(context).shadowColor)
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: Column(children: [
                              Row( children: [

                                Expanded(
                                  child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Container(
                                      height: 17, width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        color: Theme.of(context).shadowColor,
                                      ),
                                    ),

                                    const SizedBox(height: Dimensions.paddingSizeSmall,),
                                    Container(
                                      height: 17, width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        color: Theme.of(context).shadowColor,
                                      ),
                                    ),

                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                                    Container(
                                      height: 17, width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        color: Theme.of(context).shadowColor,
                                      ),
                                    )
                                  ]),
                                ),

                                const SizedBox(width: Dimensions.paddingSizeLarge,),

                                InkWell(
                                  onTap: () => Get.back(),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall + 5, vertical: Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: Theme.of(context).shadowColor,
                                    ),
                                    child:  Icon(HeroiconsOutline.arrowRight, size: 20, color: Colors.white.withValues(alpha: 0.8),),
                                  ),
                                )
                              ],)
                            ],),
                          ))
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge * 2,),

              Align(
                alignment: Alignment.center,
                child: AnimatedSmoothIndicator(
                  activeIndex: 0,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    dotHeight: 7,
                    dotWidth: 7,
                    spacing: 5,
                    activeDotColor: Theme.of(context).disabledColor,
                    dotColor: Theme.of(context).hintColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
            ],
          ),
        ),
      ),
    );
  }
}