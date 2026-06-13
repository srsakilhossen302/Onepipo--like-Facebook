import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../Utils/ToastMessage/toast_message.dart';
import '../CreateAccountScreen/Controller/create_account_controller.dart';
import 'Controller/my_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final MyProfileController controller = Get.find<MyProfileController>();

  final _fullNameController = TextEditingController(text: 'rifad');
  final _usernameController = TextEditingController(text: 'rifad22');
  final _bioController = TextEditingController(text: 'sjdjd djdbd d');

  String? _selectedCountry;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
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
        title: Text(
          StaticString.editProfile.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          final selectedCountryVal = controller.countriesList.any((c) => c.name == _selectedCountry)
              ? _selectedCountry
              : (controller.countriesList.isNotEmpty ? controller.countriesList.first.name : null);

          final countryModel = controller.countriesList.firstWhereOrNull(
            (c) => c.name == selectedCountryVal,
          );
          
          final currentCities = countryModel?.cities ?? [];

          final selectedCityVal = currentCities.any((c) => c.name == _selectedCity)
              ? _selectedCity
              : (currentCities.isNotEmpty ? currentCities.first.name : null);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full name',
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF2F3F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(color: Color(0xFF04070D), fontSize: 15),
                ),
                const SizedBox(height: 16),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF2F3F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(color: Color(0xFF04070D), fontSize: 15),
                ),
                const SizedBox(height: 20),

                // Country Label
                Text(
                  'Select your country',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // Country Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCountryVal,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF2F3F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  dropdownColor: Colors.white,
                  items: controller.countriesList.map((country) {
                    return DropdownMenuItem<String>(
                      value: country.name,
                      child: Text(country.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCountry = val;
                      _selectedCity = null;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // City Label
                Text(
                  'Select your city',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // City Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCityVal,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF2F3F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  dropdownColor: Colors.white,
                  items: currentCities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city.name,
                      child: Text(city.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCity = val;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Bio
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Bio (optional)',
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF2F3F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(color: Color(0xFF04070D), fontSize: 15),
                ),
                const SizedBox(height: 24),

                // Submit Button Row
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 120,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: controller.isLoadingUpdate.value
                          ? null
                          : () async {
                              final name = _fullNameController.text.trim();
                              final username = _usernameController.text.trim();
                              final bio = _bioController.text.trim();

                              if (name.isEmpty || username.isEmpty) {
                                ToastMessage.showToast(message: 'Please fill in required fields');
                                return;
                              }

                              final countryModelForSubmit = controller.countriesList.firstWhereOrNull(
                                (c) => c.name.toLowerCase() == (selectedCountryVal ?? '').toLowerCase(),
                              );
                              final countryId = countryModelForSubmit != null ? countryModelForSubmit.id.toString() : '1';
                              
                              final cityModelForSubmit = countryModelForSubmit?.cities.firstWhereOrNull(
                                (c) => c.name.toLowerCase() == (selectedCityVal ?? '').toLowerCase(),
                              );
                              final cityId = cityModelForSubmit != null ? cityModelForSubmit.id.toString() : '1';

                              final success = await controller.updateProfileData(
                                names: name,
                                username: username,
                                bio: bio,
                                countryId: countryId,
                                cityId: cityId,
                              );

                              if (success) {
                                Get.back();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF1877F2).withOpacity(0.6),
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: controller.isLoadingUpdate.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SUBMIT',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
