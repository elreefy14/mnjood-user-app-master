import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/util/images.dart';
import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit, this.placeholder});

  @override
  Widget build(BuildContext context) {
    // Handle null or empty image URLs
    if (image.isEmpty || image == 'null') {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: height,
      width: width,
      child: Image.network(
        image,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Image.asset(
        placeholder ?? Images.placeholder,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey[300],
            child: Icon(HeroiconsOutline.photo, size: (height ?? 60) * 0.5, color: Colors.grey),
          );
        },
      ),
    );
  }
}