import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import 'Controller/otp_verification_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OtpVerificationController controller = Get.isRegistered<OtpVerificationController>()
        ? Get.find<OtpVerificationController>()
        : Get.put(OtpVerificationController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          StaticString.oneTimePassword.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.black87,
              size: 24,
            ),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              
              // Premium Circular Key Icon
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    angle: -0.7,
                    child: const Icon(
                      Icons.key_outlined,
                      size: 44,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                StaticString.oneTimePassword.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle with Bold Email Address
              Obx(() => RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: "${StaticString.enterOtpSent.tr} "),
                    TextSpan(
                      text: controller.email.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 36),

              // OTP Input wrapper card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                ),
                child: MaterialPinField(
                  length: 5,
                  keyboardType: TextInputType.number,
                  pinController: controller.otpController,
                  theme: MaterialPinTheme(
                    shape: MaterialPinShape.underlined,
                    cellSize: const Size(40, 50),
                    spacing: 8,
                    borderColor: Colors.grey[400]!,
                    focusedBorderColor: const Color(0xFF1877F2),
                    filledBorderColor: const Color(0xFF1877F2),
                    followingBorderColor: Colors.grey[400]!,
                    fillColor: Colors.transparent,
                    focusedFillColor: Colors.transparent,
                    filledFillColor: Colors.transparent,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                    entryAnimation: MaterialPinAnimation.fade,
                    animationDuration: const Duration(milliseconds: 200),
                    animateCursor: !Get.testMode,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(height: 24),

              // Resend code timer or clickable action
              Obx(() {
                if (!controller.canResend.value) {
                  final secStr = controller.timerSeconds.value.toString().padLeft(2, '0');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${StaticString.resendCodeIn.tr} ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "00:$secStr",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                } else {
                  return GestureDetector(
                    onTap: controller.resendCode,
                    child: Text(
                      StaticString.resendCode.tr,
                      style: const TextStyle(
                        color: Color(0xFF1877F2),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
              }),
              const SizedBox(height: 40),

              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1877F2).withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          StaticString.submit.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
