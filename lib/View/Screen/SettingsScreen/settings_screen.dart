import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../helper/network_img/network_img.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = RxBool(false);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Profile Card
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  NetworkImg(
                    imageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                    width: 60,
                    height: 60,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Shahriar Kabir",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "shahriar.kabir@example.com",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Settings options group
            _buildSettingsSection(
              title: "Preferences",
              children: [
                Obx(() => ListTile(
                  leading: const Icon(Icons.dark_mode_outlined, color: AppColors.textLight),
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w500),
                  ),
                  trailing: Switch(
                    value: isDarkMode.value,
                    onChanged: (val) {
                      isDarkMode.value = val;
                      Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    },
                    activeColor: const Color(0xFF1877F2),
                  ),
                )),
                _buildSettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: "Notifications",
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.language_rounded,
                  title: "Language",
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildSettingsSection(
              title: "Security & Privacy",
              children: [
                _buildSettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: "Change Password",
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Settings",
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSettingsSection(
              title: "Support",
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: "Help Center",
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: "About Onepipo",
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.textLight),
          title: Text(
            title,
            style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 56, thickness: 0.5, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}
