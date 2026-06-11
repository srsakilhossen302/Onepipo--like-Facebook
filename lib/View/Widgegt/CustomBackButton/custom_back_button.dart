import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onTap;

  const CustomBackButton({
    super.key,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.back(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: color ?? AppColors.textLight,
        ),
      ),
    );
  }
}
