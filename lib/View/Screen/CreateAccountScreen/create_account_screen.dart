import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import 'Controller/create_account_controller.dart';

class CreateAccountScreen extends GetView<CreateAccountController> {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of countries for dropdown selection
    final List<String> countries = [
      'Bangladesh',
      'United States',
      'United Kingdom',
      'Canada',
      'France',
      'Germany',
      'India',
      'Saudi Arabia',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: 20,
                  ),
                  onPressed: controller.handleBack,
                ),
                // Linear Progress Indicator
                Obx(() => ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    width: 180,
                    height: 4,
                    child: LinearProgressIndicator(
                      value: controller.currentStep.value == 1 ? 0.5 : 1.0,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
                    ),
                  ),
                )),
                // Step Counter Text
                Obx(() => Text(
                  StaticString.stepProgressText.trParams({
                    'step': controller.currentStep.value.toString(),
                  }),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.currentStep.value == 1) ...[
                // Header Title
                Center(
                  child: Text(
                    StaticString.createAccount.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Header Subtitle
                Center(
                  child: Text(
                    StaticString.letsGetStarted.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Profile Image Picker
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: controller.openGallery,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF2F3F5),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: controller.profilePhotoPath.value.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 60,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.file(
                                    File(controller.profilePhotoPath.value),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      // Camera Icon Overlay
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: controller.openGallery,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1877F2),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Referral code field
                Text(
                  StaticString.referralCodeOptional.tr,
                  style: const TextStyle(
                    fontSize: 15,
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
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 8.0),
                        child: Icon(
                          Icons.code_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.referralController,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textLight,
                          ),
                          decoration: const InputDecoration(
                            hintText: "GT9UG67Q",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Full name field
                Text(
                  StaticString.fullName.tr,
                  style: const TextStyle(
                    fontSize: 15,
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
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 8.0),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.fullNameController,
                          keyboardType: TextInputType.name,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textLight,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Full name",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Username field
                Text(
                  StaticString.username.tr,
                  style: const TextStyle(
                    fontSize: 15,
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
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 8.0),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.usernameController,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textLight,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Username",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    StaticString.whatUsersWillSee.tr,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Email address field
                Text(
                  StaticString.emailAddress.tr,
                  style: const TextStyle(
                    fontSize: 15,
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
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 8.0),
                        child: Icon(
                          Icons.alternate_email_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textLight,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Password field
                Text(
                  StaticString.password.tr,
                  style: const TextStyle(
                    fontSize: 15,
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
                          controller: controller.passwordController,
                          obscureText: controller.isPasswordObscured.value,
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
                          controller.isPasswordObscured.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm password field
                Text(
                  StaticString.confirmPassword.tr,
                  style: const TextStyle(
                    fontSize: 15,
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
                          controller: controller.confirmPasswordController,
                          obscureText: controller.isConfirmPasswordObscured.value,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textLight,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Confirm password",
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
                          controller.isConfirmPasswordObscured.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ] else ...[
                // --- STEP 2: FINAL STEP ---
                // Header Title
                Center(
                  child: Text(
                    StaticString.finalStep.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Header Subtitle
                Center(
                  child: Text(
                    StaticString.justFewSeconds.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Select Country
                Text(
                  StaticString.selectCountry.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                  ),
                  child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<CountryModel>(
                      value: controller.countriesList.firstWhereOrNull(
                        (c) => c.name == controller.selectedCountry.value,
                      ),
                      hint: Text(
                        StaticString.selectCountry.tr,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textLight,
                      ),
                      dropdownColor: Colors.white,
                      items: controller.countriesList.map((CountryModel country) {
                        return DropdownMenuItem<CountryModel>(
                          value: country,
                          child: Text(country.name),
                        );
                      }).toList(),
                      onChanged: (CountryModel? value) {
                        controller.selectedCountry.value = value?.name;
                      },
                    ),
                  )),
                ),
                const SizedBox(height: 24),

                // Gender (optional)
                Text(
                  StaticString.genderOptional.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Male option card
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectGender('male'),
                        child: Obx(() {
                          final isSelected = controller.selectedGender.value == 'male';
                          return Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1877F2).withOpacity(0.04)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1877F2)
                                    : const Color(0xFFE5E7EB),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.male,
                                  color: isSelected
                                      ? const Color(0xFF1877F2)
                                      : Colors.black87,
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  StaticString.male.tr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF1877F2)
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Female option card
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectGender('female'),
                        child: Obx(() {
                          final isSelected = controller.selectedGender.value == 'female';
                          return Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1877F2).withOpacity(0.04)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1877F2)
                                    : const Color(0xFFE5E7EB),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.female,
                                  color: isSelected
                                      ? const Color(0xFF1877F2)
                                      : Colors.black87,
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  StaticString.female.tr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF1877F2)
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bio (optional)
                Text(
                  StaticString.bioOptional.tr,
                  style: const TextStyle(
                    fontSize: 15,
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
                  child: TextField(
                    controller: controller.bioController,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Tired of politics as usual — here to push for honesty and results.",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 48),

              // Align right - Continue / Submit button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 150,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.nextStepOrRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF1877F2).withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            controller.currentStep.value == 1
                                ? StaticString.continueText.tr
                                : StaticString.submit.tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        )),
      ),
    );
  }
}
