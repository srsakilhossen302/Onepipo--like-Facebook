import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../Utils/ToastMessage/toast_message.dart';
import '../../../helper/shared_prefe/shared_prefe.dart';
import '../../../service/api_client.dart';
import '../../../service/api_url.dart';
import '../ProfileScreen/Controller/my_profile_controller.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final SharedPreferenceHelper _sharedPref = Get.find<SharedPreferenceHelper>();
  final MyProfileController _profileController = Get.find<MyProfileController>();

  int _currentStep = 0; // 0: Intro, 1: Selection, 2: OTP
  bool _isLoading = false;

  // OTP State
  final PinInputController _otpController = PinInputController();

  // Timer State
  Timer? _timer;
  int _timerSeconds = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  Future<void> _request2faOtp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final email = _sharedPref.getUserEmail();
      final body = {
        'type': 'email',
        'credential': email.isNotEmpty ? email : 'user@example.com',
        'device_token': 'mock_device_token_xyz',
      };

      final response = await _apiClient.post(
        ApiUrl.request2fa,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _otpController.clear();
        setState(() {
          _currentStep = 2; // Move to OTP entry screen
        });
        _startTimer();
      } else {
        final errorMsg = _parseErrorMessage(response.body);
        ToastMessage.showToast(message: errorMsg ?? 'Failed to request 2FA OTP.');
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verify2faOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 5) {
      ToastMessage.showToast(message: 'Please enter the 5-digit verification code.');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final body = {
        'code': code,
      };

      final response = await _apiClient.post(
        ApiUrl.verify2fa,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update profile controller state
        _profileController.is2faEnabled.value = true;
        // Save to SharedPreferences
        await _sharedPref.setBool('is_2fa_enabled', true);

        ToastMessage.showToast(message: StaticString.twoFactorAuthEnabled.tr);
        Get.back();
      } else {
        final errorMsg = _parseErrorMessage(response.body);
        ToastMessage.showToast(message: errorMsg ?? 'Invalid verification code.');
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map && data.containsKey('message')) {
        return data['message']?.toString();
      }
    } catch (_) {}
    return null;
  }

  void _handleBack() {
    if (_isLoading) return;
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _timer?.cancel();
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textLight,
            size: 20,
          ),
          onPressed: _handleBack,
        ),
        centerTitle: true,
        title: _currentStep == 0
            ? null
            : Text(
                StaticString.twoFactorAuth.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: _buildCurrentStepView(),
              ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildIntroStep();
      case 1:
        return _buildSelectionStep();
      case 2:
        return _buildOtpStep();
      default:
        return _buildIntroStep();
    }
  }

  Widget _buildIntroStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        // Shield Icon
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8F4FD),
              border: Border.all(color: const Color(0xFF1877F2).withOpacity(0.2), width: 1.5),
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 74,
              color: Color(0xFF1877F2),
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Title
        const Text(
          "Protect your account with an extra layer of security.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 30),
        // Bullet points
        _buildIntroBullet(
          icon: Icons.lock_outline_rounded,
          text: "Prevent unauthorized access even if someone gets your password.",
        ),
        const SizedBox(height: 16),
        _buildIntroBullet(
          icon: Icons.sms_outlined,
          text: "Get a secure one-time code via SMS, email, or authenticator app.",
        ),
        const SizedBox(height: 16),
        _buildIntroBullet(
          icon: Icons.privacy_tip_outlined,
          text: "Stay in full control of your account's privacy and safety.",
        ),
        const SizedBox(height: 60),
        // Get Started Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Get started",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildIntroBullet({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.5,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // Padlock with Check Icon
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF0F2F5),
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  size: 64,
                  color: Color(0xFF1877F2),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF1877F2),
                    size: 34,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // Title
        const Text(
          "Enabling 2FA",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Choose how you'd like enable two-factor authentication",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.5,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 36),
        // Email Selection Card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1877F2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: Color(0xFF1877F2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "We will send you a verification code to your email address",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Radio selected indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1877F2), width: 2.0),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1877F2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
        // Enable Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _request2faOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Enable",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOtpStep() {
    final email = _sharedPref.getUserEmail();
    final displayEmail = email.isNotEmpty ? email : 'your email address';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // Key Icon
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.black87, width: 2.0),
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
        const Text(
          "One-Time Password",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 12),
        // Subtitle
        RichText(
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
                text: displayEmail,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        // OTP Inputs Card
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
            pinController: _otpController,
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
        // Timer/Resend code link
        _buildResendCodeSection(),
        const SizedBox(height: 40),
        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _verify2faOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              StaticString.submit.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResendCodeSection() {
    if (!_canResend) {
      final secStr = _timerSeconds.toString().padLeft(2, '0');
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
        onTap: () {
          _request2faOtp();
        },
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
  }
}
