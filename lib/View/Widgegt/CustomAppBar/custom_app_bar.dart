import 'package:flutter/material.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../CustomBackButton/custom_back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? titleColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textLight,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      leading: leading ?? (showBackButton ? const CustomBackButton() : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
