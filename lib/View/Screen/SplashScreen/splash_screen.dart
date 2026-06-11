import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import 'Controller/splash_screen_controller.dart';

class SplashScreen extends GetView<SplashScreenController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Branding Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clean circular wrapper for logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/App-Logo.svg',
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 30),
                
                Text(
                  StaticString.appName.tr,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                    letterSpacing: 2,
                  ),
                ),
                // const SizedBox(height: 12),
                
                // Text(
                //   StaticString.splashSubtitle.tr,
                //   textAlign: TextAlign.center,
                //   style: const TextStyle(
                //     fontSize: 14,
                //     color: AppColors.textMutedLight,
                //     fontWeight: FontWeight.w400,
                //     letterSpacing: 0.5,
                //   ),
                // ),
              ],
            ),
            
            // Loading indicator at the bottom
            const Positioned(
              bottom: 80,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
