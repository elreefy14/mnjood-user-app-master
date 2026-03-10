import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/helper/marker_helper.dart';
import 'package:mnjood/helper/position_interpolator.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EmbeddedTrackingWidget extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onChatTap;

  const EmbeddedTrackingWidget({
    super.key,
    required this.order,
    this.onChatTap,
  });

  @override
  State<EmbeddedTrackingWidget> createState() => _EmbeddedTrackingWidgetState();
}

class _EmbeddedTrackingWidgetState extends State<EmbeddedTrackingWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupMarkers();
  }

  @override
  void didUpdateWidget(EmbeddedTrackingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update markers when order data changes (e.g., driver location updates)
    if (oldWidget.order.deliveryMan?.lat != widget.order.deliveryMan?.lat ||
        oldWidget.order.deliveryMan?.lng != widget.order.deliveryMan?.lng) {
      _setupMarkers();
    }
  }

  Future<void> _setupMarkers() async {
    final deliveryMan = widget.order.deliveryMan;
    final deliveryAddress = widget.order.deliveryAddress;

    if (deliveryMan == null) return;

    try {
      final driverIcon = await MarkerHelper.create3DDriverMarker();
      final destinationIcon = BitmapDescriptor.defaultMarker;

      Set<Marker> newMarkers = {};

      // Driver marker
      final driverLat = double.tryParse(deliveryMan.lat ?? '0') ?? 0;
      final driverLng = double.tryParse(deliveryMan.lng ?? '0') ?? 0;

      if (driverLat != 0 && driverLng != 0) {
        newMarkers.add(Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(driverLat, driverLng),
          icon: driverIcon,
          infoWindow: InfoWindow(title: '${deliveryMan.fName ?? ''} ${deliveryMan.lName ?? ''}'),
        ));
      }

      // Destination marker
      if (deliveryAddress != null) {
        final destLat = double.tryParse(deliveryAddress.latitude ?? '') ?? 0;
        final destLng = double.tryParse(deliveryAddress.longitude ?? '') ?? 0;

        if (destLat != 0 && destLng != 0) {
          newMarkers.add(Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(destLat, destLng),
            icon: destinationIcon,
            infoWindow: InfoWindow(title: 'delivery_address'.tr),
          ));
        }
      }

      if (mounted) {
        setState(() {
          _markers = newMarkers;
          _isLoading = false;
        });

        // Fit camera to show both markers
        if (_mapController != null && newMarkers.length >= 2) {
          _fitBounds();
        }
      }
    } catch (e) {
      debugPrint('Error setting up markers: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fitBounds() {
    if (_markers.length < 2) return;

    final positions = _markers.map((m) => m.position).toList();
    double minLat = positions.map((p) => p.latitude).reduce(min);
    double maxLat = positions.map((p) => p.latitude).reduce(max);
    double minLng = positions.map((p) => p.longitude).reduce(min);
    double maxLng = positions.map((p) => p.longitude).reduce(max);

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  int _calculateETA() {
    final deliveryMan = widget.order.deliveryMan;
    final deliveryAddress = widget.order.deliveryAddress;
    if (deliveryMan == null || deliveryAddress == null) return 0;

    final driverLat = double.tryParse(deliveryMan.lat ?? '0') ?? 0;
    final driverLng = double.tryParse(deliveryMan.lng ?? '0') ?? 0;
    final destLat = double.tryParse(deliveryAddress.latitude ?? '') ?? 0;
    final destLng = double.tryParse(deliveryAddress.longitude ?? '') ?? 0;
    if (driverLat == 0 || driverLng == 0 || destLat == 0 || destLng == 0) return 0;

    return PositionInterpolator.calculateETAMinutes(
      LatLng(driverLat, driverLng),
      LatLng(destLat, destLng),
    );
  }

  double _calculateDistance() {
    final deliveryMan = widget.order.deliveryMan;
    final deliveryAddress = widget.order.deliveryAddress;
    if (deliveryMan == null || deliveryAddress == null) return 0;

    final driverLat = double.tryParse(deliveryMan.lat ?? '0') ?? 0;
    final driverLng = double.tryParse(deliveryMan.lng ?? '0') ?? 0;
    final destLat = double.tryParse(deliveryAddress.latitude ?? '') ?? 0;
    final destLng = double.tryParse(deliveryAddress.longitude ?? '') ?? 0;
    if (driverLat == 0 || driverLng == 0 || destLat == 0 || destLng == 0) return 0;

    return PositionInterpolator.calculateDistance(
      LatLng(driverLat, driverLng),
      LatLng(destLat, destLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryMan = widget.order.deliveryMan;

    if (deliveryMan == null) return const SizedBox.shrink();

    final driverLat = double.tryParse(deliveryMan.lat ?? '0') ?? 0;
    final driverLng = double.tryParse(deliveryMan.lng ?? '0') ?? 0;

    // Don't show if driver has no location
    if (driverLat == 0 && driverLng == 0) return const SizedBox.shrink();

    final etaMinutes = _calculateETA();
    final distance = _calculateDistance();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with ETA
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Dimensions.radiusDefault),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delivery_dining,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'driver_on_the_way'.tr,
                        style: robotoBold.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      if (etaMinutes > 0)
                        Text(
                          '${'estimated_arrival'.tr}: $etaMinutes ${'min'.tr} • ${PositionInterpolator.formatDistance(distance)}',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map
          SizedBox(
            height: 180,
            child: ClipRRect(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(driverLat, driverLng),
                      zoom: 14,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _fitBounds();
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    style: Get.isDarkMode
                        ? Get.find<ThemeController>().darkMap
                        : Get.find<ThemeController>().lightMap,
                  ),
                  if (_isLoading)
                    Container(
                      color: Theme.of(context).cardColor,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),

          // Driver info
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                // Driver avatar
                CircleAvatar(
                  radius: 24,
                  backgroundImage: deliveryMan.imageFullUrl != null
                      ? NetworkImage(deliveryMan.imageFullUrl!)
                      : null,
                  child: deliveryMan.imageFullUrl == null
                      ? Icon(HeroiconsOutline.user, size: 24)
                      : null,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                // Driver name and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${deliveryMan.fName ?? ''} ${deliveryMan.lName ?? ''}',
                        style: robotoBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (deliveryMan.avgRating != null && deliveryMan.avgRating! > 0)
                        Row(
                          children: [
                            Icon(
                              HeroiconsSolid.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              deliveryMan.avgRating!.toStringAsFixed(1),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Call button
                if (deliveryMan.phone != null)
                  IconButton(
                    onPressed: () => launchUrlString('tel:${deliveryMan.phone}'),
                    icon: Icon(
                      HeroiconsSolid.phone,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                // Chat button
                if (widget.onChatTap != null)
                  IconButton(
                    onPressed: widget.onChatTap,
                    icon: Icon(
                      HeroiconsSolid.chatBubbleLeftRight,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
