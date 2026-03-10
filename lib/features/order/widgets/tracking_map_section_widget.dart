import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/features/location/widgets/permission_dialog.dart';
import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/order/widgets/animated_route_polyline.dart';
import 'package:mnjood/features/order/widgets/substitution_bottom_sheet.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/helper/directions_helper.dart';
import 'package:mnjood/helper/marker_helper.dart';
import 'package:mnjood/helper/position_interpolator.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class TrackingMapSectionWidget extends StatefulWidget {
  final String orderID;
  final String? contactNumber;
  final OrderModel track;
  final double height;

  const TrackingMapSectionWidget({
    super.key,
    required this.orderID,
    this.contactNumber,
    required this.track,
    this.height = 300,
  });

  @override
  State<TrackingMapSectionWidget> createState() => _TrackingMapSectionWidgetState();
}

class _TrackingMapSectionWidgetState extends State<TrackingMapSectionWidget> with TickerProviderStateMixin {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polyline> _polylines = {};
  Timer? _timer;
  final PositionInterpolator _positionInterpolator = PositionInterpolator();
  AnimationController? _markerAnimationController;

  DateTime _lastUpdated = DateTime.now();
  bool _isRefreshing = false;

  // Road route cache
  List<LatLng>? _cachedRoutePoints;
  bool _isFetchingRoute = false;

  @override
  void initState() {
    super.initState();
    _markerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _startTracking();
  }

  void _startTracking() {
    final orderController = Get.find<OrderController>();
    final status = orderController.trackModel?.orderStatus;
    if (status != 'delivered' && status != 'failed' && status != 'canceled') {
      orderController.timerTrackOrder(widget.orderID, contactNumber: widget.contactNumber);
      _timer?.cancel();
      _timer = Timer.periodic(
        Duration(seconds: status == 'picked_up' ? 5 : 10),
        (timer) {
          if (Get.currentRoute.contains(RouteHelper.orderDetails) || Get.currentRoute.contains(RouteHelper.orderTracking)) {
            orderController.timerTrackOrder(widget.orderID, contactNumber: widget.contactNumber);
            _lastUpdated = DateTime.now();

            final track = orderController.trackModel;
            if (track != null) {
              updateMarker(
                track.restaurant,
                track.deliveryMan,
                track.orderType == 'take_away'
                    ? Get.find<LocationController>().position.latitude == 0
                        ? track.deliveryAddress
                        : AddressModel(
                            latitude: Get.find<LocationController>().position.latitude.toString(),
                            longitude: Get.find<LocationController>().position.longitude.toString(),
                            address: Get.find<LocationController>().address,
                          )
                    : track.deliveryAddress,
                track.orderType == 'take_away',
              );
            }
          } else {
            _timer?.cancel();
          }
        },
      );
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();
    try {
      await Get.find<OrderController>().trackOrder(widget.orderID, null, true, contactNumber: widget.contactNumber);
      _lastUpdated = DateTime.now();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  String _getTimeAgo() {
    final difference = DateTime.now().difference(_lastUpdated);
    if (difference.inSeconds < 60) return '${difference.inSeconds} ${'seconds_ago'.tr}';
    if (difference.inMinutes < 60) return '${difference.inMinutes} ${'min'.tr}';
    return '${difference.inHours}h';
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    _markerAnimationController?.dispose();
    DirectionsHelper.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      final track = orderController.trackModel ?? widget.track;

      return SizedBox(
        height: widget.height,
        child: Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                double.tryParse(track.deliveryAddress?.latitude ?? '') ?? 24.7136,
                double.tryParse(track.deliveryAddress?.longitude ?? '') ?? 46.6753,
              ),
              zoom: 16,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
            zoomControlsEnabled: false,
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              _isLoading = false;
              setMarker(
                track.restaurant,
                track.deliveryMan,
                track.orderType == 'take_away'
                    ? Get.find<LocationController>().position.latitude == 0
                        ? track.deliveryAddress
                        : AddressModel(
                            latitude: Get.find<LocationController>().position.latitude.toString(),
                            longitude: Get.find<LocationController>().position.longitude.toString(),
                            address: Get.find<LocationController>().address,
                          )
                    : track.deliveryAddress,
                track.orderType == 'take_away',
              );
            },
            style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
          ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // Substitution banner
          if (orderController.pendingSubstitutions.isNotEmpty)
            Positioned(
              top: 10, left: 10, right: 10,
              child: GestureDetector(
                onTap: () => showSubstitutionBottomSheet(orderId: int.tryParse(widget.orderID) ?? 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(children: [
                    const Icon(Icons.swap_horiz, color: Colors.orange, size: 22),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      '${'substitution_available'.tr} (${orderController.pendingSubstitutions.length})',
                      style: robotoMedium.copyWith(color: Colors.orange.shade900),
                    )),
                    const Icon(Icons.chevron_right, color: Colors.orange),
                  ]),
                ),
              ),
            ),

          // Relocate button
          Positioned(
            right: 10, bottom: 50,
            child: InkWell(
              onTap: () => _checkPermission(() async {
                final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                _controller?.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 16),
                ));
              }),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                child: Icon(HeroiconsOutline.viewfinderCircle, color: Theme.of(context).primaryColor, size: 25),
              ),
            ),
          ),

          // Current location button
          Positioned(
            right: 10, bottom: 10,
            child: InkWell(
              onTap: () => _checkPermission(() async {
                AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                setMarker(
                  track.restaurant, track.deliveryMan,
                  track.orderType == 'take_away'
                      ? Get.find<LocationController>().position.latitude == 0
                          ? track.deliveryAddress
                          : AddressModel(
                              latitude: Get.find<LocationController>().position.latitude.toString(),
                              longitude: Get.find<LocationController>().position.longitude.toString(),
                              address: Get.find<LocationController>().address,
                            )
                      : track.deliveryAddress,
                  track.orderType == 'take_away',
                  currentAddress: address, fromCurrentLocation: true,
                );
              }),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                child: Icon(HeroiconsOutline.mapPin, color: Theme.of(context).primaryColor, size: 25),
              ),
            ),
          ),

          // Last updated indicator
          Positioned(
            left: 10, bottom: 10,
            child: GestureDetector(
              onTap: _handleRefresh,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isRefreshing)
                      SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                      )
                    else
                      Icon(HeroiconsOutline.arrowPath, size: 14, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      _isRefreshing ? 'loading'.tr : '${'last_updated'.tr}: ${_getTimeAgo()}',
                      style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      );
    });
  }

  Future<void> _fetchRouteIfNeeded(LatLng restaurant, LatLng destination, LatLng? rider) async {
    debugPrint('_fetchRouteIfNeeded: cached=${_cachedRoutePoints?.length}, fetching=$_isFetchingRoute, rider=$rider');
    if (_cachedRoutePoints == null && !_isFetchingRoute) {
      _isFetchingRoute = true;
      try {
        final points = await DirectionsHelper.getRoutePoints(restaurant, destination);
        if (points.length > 2) {
          _cachedRoutePoints = points;
          debugPrint('_fetchRouteIfNeeded: got road route with ${points.length} points');
        } else {
          debugPrint('_fetchRouteIfNeeded: got straight-line fallback, will retry next time');
        }
      } finally {
        _isFetchingRoute = false;
      }
      return;
    }

    if (rider != null && _cachedRoutePoints != null && !_isFetchingRoute) {
      if (DirectionsHelper.isOffRoute(_cachedRoutePoints!, rider)) {
        _isFetchingRoute = true;
        try {
          final newSegment = await DirectionsHelper.getRoutePoints(rider, destination);
          if (newSegment.length > 2) {
            final split = DirectionsHelper.splitRouteAtRider(_cachedRoutePoints!, rider);
            _cachedRoutePoints = [...split.completed, ...newSegment.skip(1)];
            debugPrint('_fetchRouteIfNeeded: re-routed with ${_cachedRoutePoints!.length} points');
          } else {
            debugPrint('_fetchRouteIfNeeded: re-route got fallback, keeping old route');
          }
        } finally {
          _isFetchingRoute = false;
        }
      }
    }
  }

  void setMarker(Restaurant? restaurant, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway, {AddressModel? currentAddress, bool fromCurrentLocation = false}) async {
    if (addressModel?.latitude == null || addressModel?.longitude == null) return;
    if (restaurant?.latitude == null || restaurant?.longitude == null) return;

    try {
      BitmapDescriptor restaurantImageData = await MarkerHelper.createHeroiconMarker(
        icon: HeroiconsSolid.buildingStorefront, backgroundColor: const Color(0xFFff9e1b), size: 28,
      );
      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.create3DDriverMarker();
      BitmapDescriptor destinationImageData = BitmapDescriptor.defaultMarker;

      final addressLat = double.tryParse(addressModel!.latitude!) ?? 24.7136;
      final addressLng = double.tryParse(addressModel.longitude!) ?? 46.6753;
      final restaurantLat = double.tryParse(restaurant!.latitude!) ?? 24.7136;
      final restaurantLng = double.tryParse(restaurant.longitude!) ?? 46.6753;

      LatLngBounds? bounds;
      double rotation = 0;
      if (_controller != null) {
        if (addressLat < restaurantLat) {
          bounds = LatLngBounds(southwest: LatLng(addressLat, addressLng), northeast: LatLng(restaurantLat, restaurantLng));
        } else {
          bounds = LatLngBounds(southwest: LatLng(restaurantLat, restaurantLng), northeast: LatLng(addressLat, addressLng));
          rotation = 180;
        }
      }

      LatLng centerBounds = bounds != null
          ? LatLng((bounds.northeast.latitude + bounds.southwest.latitude) / 2, (bounds.northeast.longitude + bounds.southwest.longitude) / 2)
          : LatLng(addressLat, addressLng);

      if (fromCurrentLocation && currentAddress != null && currentAddress.latitude != null && currentAddress.longitude != null) {
        LatLng currentLocation = LatLng(double.tryParse(currentAddress.latitude!) ?? addressLat, double.tryParse(currentAddress.longitude!) ?? addressLng);
        _controller?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLocation, zoom: GetPlatform.isWeb ? 7 : 15)));
      }

      if (!fromCurrentLocation && _controller != null) {
        _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 7 : 15)));
        if (!ResponsiveHelper.isWeb() && bounds != null) {
          zoomToFit(_controller, bounds, centerBounds, padding: 3.5);
        }
      }

      _markers = HashSet<Marker>();

      if (currentAddress != null && currentAddress.latitude != null && currentAddress.longitude != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'), visible: true, draggable: false,
          zIndexInt: 2, flat: true, anchor: const Offset(0.5, 0.5),
          position: LatLng(double.tryParse(currentAddress.latitude!) ?? addressLat, double.tryParse(currentAddress.longitude!) ?? addressLng),
          icon: destinationImageData,
        ));
        if (mounted) setState(() {});
      }

      if (currentAddress == null) {
        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(addressLat, addressLng),
          infoWindow: InfoWindow(title: 'Destination', snippet: addressModel.address),
          icon: destinationImageData,
        ));
      }

      _markers.add(Marker(
        markerId: const MarkerId('restaurant'),
        position: LatLng(restaurantLat, restaurantLng),
        infoWindow: InfoWindow(title: 'restaurant'.tr, snippet: restaurant.address),
        icon: restaurantImageData,
      ));

      if (deliveryMan != null) {
        final driverBearing = Get.find<OrderController>().driverBearing;
        _markers.add(Marker(
          markerId: const MarkerId('delivery_boy'),
          position: LatLng(double.tryParse(deliveryMan.lat ?? '0') ?? 0, double.tryParse(deliveryMan.lng ?? '0') ?? 0),
          infoWindow: InfoWindow(title: 'delivery_man'.tr, snippet: deliveryMan.location),
          flat: true, anchor: const Offset(0.5, 0.5),
          icon: deliveryBoyImageData,
        ));
      }

      final restaurantPos = LatLng(restaurantLat, restaurantLng);
      final destinationPos = LatLng(addressLat, addressLng);
      final riderPos = deliveryMan != null
          ? LatLng(double.tryParse(deliveryMan.lat ?? '0') ?? 0, double.tryParse(deliveryMan.lng ?? '0') ?? 0)
          : restaurantPos;
      final orderStatus = Get.find<OrderController>().trackModel?.orderStatus ?? '';

      await _fetchRouteIfNeeded(restaurantPos, destinationPos, deliveryMan != null ? riderPos : null);

      if (_cachedRoutePoints != null && _cachedRoutePoints!.length >= 2) {
        if (orderStatus == 'picked_up' || orderStatus == 'handover') {
          final split = DirectionsHelper.splitRouteAtRider(_cachedRoutePoints!, riderPos);
          _polylines = RoutePolylineBuilder.buildRoadRoutePolylines(
            completedPoints: split.completed,
            remainingPoints: split.remaining,
            orderStatus: orderStatus,
          );
        } else {
          _polylines = RoutePolylineBuilder.buildRoadRoutePolylines(
            completedPoints: [],
            remainingPoints: _cachedRoutePoints!,
            orderStatus: orderStatus,
          );
        }
      } else {
        _polylines = RoutePolylineBuilder.buildTrackingPolylines(
          restaurantPosition: restaurantPos, riderPosition: riderPos, destinationPosition: destinationPos, orderStatus: orderStatus,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('setMarker error: $e\n$stackTrace');
    }
    if (mounted) setState(() {});
  }

  void updateMarker(Restaurant? restaurant, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway) async {
    if (addressModel?.latitude == null || addressModel?.longitude == null) return;
    if (restaurant?.latitude == null || restaurant?.longitude == null) return;

    try {
      BitmapDescriptor restaurantImageData = await MarkerHelper.createHeroiconMarker(
        icon: HeroiconsSolid.buildingStorefront, backgroundColor: const Color(0xFFff9e1b), size: 28,
      );
      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.create3DDriverMarker();

      final addressLat = double.tryParse(addressModel!.latitude!) ?? 24.7136;
      final addressLng = double.tryParse(addressModel.longitude!) ?? 46.6753;
      final restaurantLat = double.tryParse(restaurant!.latitude!) ?? 24.7136;
      final restaurantLng = double.tryParse(restaurant.longitude!) ?? 46.6753;

      double rotation = 0;
      if (_controller != null) {
        if (addressLat >= restaurantLat) rotation = 180;
      }

      _markers = HashSet<Marker>();

      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(addressLat, addressLng),
        infoWindow: InfoWindow(title: 'Destination', snippet: addressModel.address),
        icon: BitmapDescriptor.defaultMarker,
      ));

      _markers.add(Marker(
        markerId: const MarkerId('restaurant'),
        position: LatLng(restaurantLat, restaurantLng),
        infoWindow: InfoWindow(title: 'restaurant'.tr, snippet: restaurant.address),
        icon: restaurantImageData,
      ));

      if (deliveryMan != null) {
        final driverBearing = Get.find<OrderController>().driverBearing;
        _markers.add(Marker(
          markerId: const MarkerId('delivery_boy'),
          position: LatLng(double.tryParse(deliveryMan.lat ?? '0') ?? 0, double.tryParse(deliveryMan.lng ?? '0') ?? 0),
          infoWindow: InfoWindow(title: 'delivery_man'.tr, snippet: deliveryMan.location),
          flat: true, anchor: const Offset(0.5, 0.5),
          icon: deliveryBoyImageData,
        ));
      }

      final restaurantPos = LatLng(restaurantLat, restaurantLng);
      final destinationPos = LatLng(addressLat, addressLng);
      final newRiderPos = deliveryMan != null
          ? LatLng(double.tryParse(deliveryMan.lat ?? '0') ?? 0, double.tryParse(deliveryMan.lng ?? '0') ?? 0)
          : restaurantPos;

      _positionInterpolator.updatePosition(newRiderPos);

      final orderStatus = Get.find<OrderController>().trackModel?.orderStatus ?? '';

      await _fetchRouteIfNeeded(restaurantPos, destinationPos, deliveryMan != null ? newRiderPos : null);

      if (_cachedRoutePoints != null && _cachedRoutePoints!.length >= 2) {
        if (orderStatus == 'picked_up' || orderStatus == 'handover') {
          final split = DirectionsHelper.splitRouteAtRider(_cachedRoutePoints!, newRiderPos);
          _polylines = RoutePolylineBuilder.buildRoadRoutePolylines(
            completedPoints: split.completed,
            remainingPoints: split.remaining,
            orderStatus: orderStatus,
          );
        } else {
          _polylines = RoutePolylineBuilder.buildRoadRoutePolylines(
            completedPoints: [],
            remainingPoints: _cachedRoutePoints!,
            orderStatus: orderStatus,
          );
        }
      } else {
        _polylines = RoutePolylineBuilder.buildTrackingPolylines(
          restaurantPosition: restaurantPos, riderPosition: newRiderPos, destinationPosition: destinationPos, orderStatus: orderStatus,
        );
      }

      if ((orderStatus == 'picked_up' || orderStatus == 'handover') && _controller != null) {
        _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newRiderPos, zoom: 16)));
      }
    } catch (e, stackTrace) {
      debugPrint('updateMarker error: $e\n$stackTrace');
    }
    if (mounted) setState(() {});
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;
    while (keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if (_fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: zoomLevel)));
        break;
      } else {
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: zoomLevel)));
      }
    }
  }

  bool _fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    return screenBounds.northeast.latitude >= fitBounds.northeast.latitude &&
        screenBounds.northeast.longitude >= fitBounds.northeast.longitude &&
        screenBounds.southwest.latitude <= fitBounds.southwest.latitude &&
        screenBounds.southwest.longitude <= fitBounds.southwest.longitude;
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    } else {
      onTap();
    }
  }
}
