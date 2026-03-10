import 'package:cached_network_image/cached_network_image.dart';
import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/util/images.dart';
import 'package:flutter/material.dart';

class CustomImageWidget extends StatefulWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String placeholder;
  final Color? imageColor;
  final bool isRestaurant;
  final bool isFood;
  final Color? color;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.placeholder = '', this.imageColor,
    this.isRestaurant = false, this.isFood = false, this.color});

  @override
  State<CustomImageWidget> createState() => _CustomImageWidgetState();
}

class _CustomImageWidgetState extends State<CustomImageWidget> {
  bool _isHovered = false;

  /// Check if the URL is valid (non-empty and starts with http/https)
  bool _isValidUrl(String url) {
    return url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    // Get placeholder image based on type
    String placeholderImage = widget.placeholder.isNotEmpty
        ? widget.placeholder
        : widget.isRestaurant
            ? Images.restaurantPlaceholder
            : widget.isFood
                ? Images.foodPlaceholder
                : Images.placeholderPng;

    // If URL is invalid, show placeholder directly
    if (!_isValidUrl(widget.image)) {
      return CustomAssetImageWidget(
        placeholderImage,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        color: widget.imageColor,
      );
    }

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedScale(
        scale: _isHovered ? 1.2 : 1.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: CachedNetworkImage(
          color: widget.color,
          imageUrl: widget.image,
          height: widget.height, width: widget.width, fit: widget.fit,
          placeholder: (context, url) => CustomAssetImageWidget(placeholderImage,
              height: widget.height, width: widget.width, fit: widget.fit, color: widget.imageColor),
          errorWidget: (context, url, error) => CustomAssetImageWidget(placeholderImage,
              height: widget.height, width: widget.width, fit: widget.fit, color: widget.imageColor),
        ),
      ),
    );
  }
}
