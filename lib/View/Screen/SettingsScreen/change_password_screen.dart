import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../Utils/ToastMessage/toast_message.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleUpdatePassword() {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ToastMessage.showToast(message: StaticString.pleaseFillAllFields.tr);
      return;
    }

    if (newPass.length < 6) {
      ToastMessage.showToast(message: StaticString.passwordTooShort.tr);
      return;
    }

    if (newPass != confirm) {
      ToastMessage.showToast(message: StaticString.passwordsDoNotMatch.tr);
      return;
    }

    // Success
    ToastMessage.showToast(message: StaticString.passwordUpdatedSuccess.tr);
    Get.back();
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
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          StaticString.changePassword.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Custom Blue Header Logo: |**
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1877F2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "**",
                        style: TextStyle(
                          color: Color(0xFF1877F2),
                          fontSize: 82,
                          fontWeight: FontWeight.bold,
                          height: 0.95,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Reset Password Header Text
                Text(
                  StaticString.resetPassword.tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 28),

                // Current Password Field
                _buildPasswordField(
                  label: StaticString.currentPassword.tr,
                  controller: _currentPasswordController,
                  isObscured: _isCurrentPasswordObscured,
                  onToggleVisibility: () {
                    setState(() {
                      _isCurrentPasswordObscured = !_isCurrentPasswordObscured;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // New Password Field
                _buildPasswordField(
                  label: StaticString.newPassword.tr,
                  controller: _newPasswordController,
                  isObscured: _isNewPasswordObscured,
                  onToggleVisibility: () {
                    setState(() {
                      _isNewPasswordObscured = !_isNewPasswordObscured;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                _buildPasswordField(
                  label: StaticString.passwordConfirmation.tr,
                  controller: _confirmPasswordController,
                  isObscured: _isConfirmPasswordObscured,
                  onToggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                    });
                  },
                ),
                const SizedBox(height: 40),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleUpdatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      StaticString.update.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
          ),
          child: Row(
            children: [
              // Custom prefix |**
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Text(
                  "|**",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: isObscured,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textLight,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[500],
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }
}
