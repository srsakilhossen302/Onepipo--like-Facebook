import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../Utils/AppColors/app_colors.dart';

class NetworkImg extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  const NetworkImg({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: AppColors.borderLight.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: AppColors.borderLight.withOpacity(0.5),
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textMutedLight,
            ),
          ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
