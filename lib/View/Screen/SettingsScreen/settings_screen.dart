import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../Core/AppRoute/app_route.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../Utils/ToastMessage/toast_message.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle states
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _twoFactorAuth = false;
  bool _anonymousMode = false;

  Widget _buildCustomSwitch({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? const Color(0xFF1877F2) : const Color(0xFFE4E6EB),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Text label: "ON" or "OFF"
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? const Alignment(-0.45, 0.0) : const Alignment(0.45, 0.0),
              child: Text(
                value ? StaticString.switchOn.tr : StaticString.switchOff.tr,
                style: TextStyle(
                  color: value ? Colors.white : const Color(0xFF65676B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Circular Thumb
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    IconData? icon,
    String? iconAsset,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    Widget leadingWidget;
    if (iconAsset != null) {
      leadingWidget = SvgPicture.asset(
        iconAsset,
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(
          Color(0xFF0F1419),
          BlendMode.srcIn,
        ),
      );
    } else {
      leadingWidget = Icon(
        icon,
        color: const Color(0xFF0F1419),
        size: 20,
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F3F5),
          shape: BoxShape.circle,
        ),
        child: Center(child: leadingWidget),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12.5,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 24,
      ),
      onTap: onTap,
    );
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
          StaticString.settings.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card Section
            InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F3F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 48,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Shahriar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "krabbi505@gmail.com",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),

            // Account Section
            _buildSectionHeader(StaticString.account.tr),
            _buildSettingsTile(
              iconAsset: 'assets/icons/Password.svg',
              title: StaticString.password.tr,
              subtitle: StaticString.changePassword.tr,
              onTap: () => Get.toNamed(AppRoute.changePassword),
            ),
            _buildSettingsTile(
              iconAsset: 'assets/icons/Email.svg',
              title: StaticString.email.tr,
              subtitle: "krabbi505@gmail.com",
              trailing: const SizedBox.shrink(),
              onTap: () {},
            ),
            _buildSettingsTile(
              iconAsset: 'assets/icons/Phone.svg',
              title: StaticString.phone.tr,
              subtitle: "N/A",
              trailing: const SizedBox.shrink(),
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.translate_rounded,
              title: StaticString.changeLanguage.tr,
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              title: StaticString.aboutAccount.tr,
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.bookmark_outline_rounded,
              title: StaticString.savePosts.tr,
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.archive_outlined,
              title: StaticString.archivedPosts.tr,
              onTap: () {},
            ),

            // Privacy Section
            _buildSectionHeader(StaticString.privacy.tr),
            _buildSettingsTile(
              iconAsset: 'assets/icons/Blocked users.svg',
              title: StaticString.blockedUsers.tr,
              subtitle: StaticString.usersBlockedDesc.tr,
              onTap: () {},
            ),
            _buildSettingsTile(
              iconAsset: 'assets/icons/Anonymous mode.svg',
              title: StaticString.anonymousMode.tr,
              subtitle: StaticString.hideIdentity.tr,
              trailing: _buildCustomSwitch(
                value: _anonymousMode,
                onChanged: (val) {
                  setState(() {
                    _anonymousMode = val;
                  });
                  ToastMessage.showToast(
                    message: val ? StaticString.anonymousModeEnabled.tr : StaticString.anonymousModeDisabled.tr,
                  );
                },
              ),
              onTap: () {},
            ),

            // Legal Section
            _buildSectionHeader(StaticString.legal.tr),
            _buildSettingsTile(
              icon: Icons.shield_outlined,
              title: StaticString.privacyPolicy.tr,
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: StaticString.termsOfUse.tr,
              onTap: () {},
            ),

            // Notifications Section
            _buildSectionHeader(StaticString.notifications.tr),
            _buildSettingsTile(
              icon: Icons.notifications_none_rounded,
              title: StaticString.pushNotifications.tr,
              subtitle: StaticString.receiveAppNotifications.tr,
              trailing: _buildCustomSwitch(
                value: _pushNotifications,
                onChanged: (val) {
                  setState(() {
                    _pushNotifications = val;
                  });
                  ToastMessage.showToast(
                    message: val ? StaticString.pushNotificationsEnabled.tr : StaticString.pushNotificationsDisabled.tr,
                  );
                },
              ),
              onTap: () {},
            ),
            _buildSettingsTile(
              iconAsset: 'assets/icons/Email notifications.svg',
              title: StaticString.emailNotifications.tr,
              subtitle: StaticString.receiveEmailUpdates.tr,
              trailing: _buildCustomSwitch(
                value: _emailNotifications,
                onChanged: (val) {
                  setState(() {
                    _emailNotifications = val;
                  });
                  ToastMessage.showToast(
                    message: val ? StaticString.emailNotificationsEnabled.tr : StaticString.emailNotificationsDisabled.tr,
                  );
                },
              ),
              onTap: () {},
            ),
            _buildSettingsTile(
              iconAsset: 'assets/icons/SMS notifications.svg',
              title: StaticString.smsNotifications.tr,
              subtitle: StaticString.receiveSmsAlerts.tr,
              trailing: _buildCustomSwitch(
                value: _smsNotifications,
                onChanged: (val) {
                  setState(() {
                    _smsNotifications = val;
                  });
                  ToastMessage.showToast(
                    message: val ? StaticString.smsNotificationsEnabled.tr : StaticString.smsNotificationsDisabled.tr,
                  );
                },
              ),
              onTap: () {},
            ),

            // Security Section
            _buildSectionHeader(StaticString.security.tr),
            _buildSettingsTile(
              iconAsset: 'assets/icons/Two-factor authentication.svg',
              title: StaticString.twoFactorAuth.tr,
              subtitle: StaticString.extraSecurityDesc.tr,
              trailing: _buildCustomSwitch(
                value: _twoFactorAuth,
                onChanged: (val) {
                  setState(() {
                    _twoFactorAuth = val;
                  });
                  ToastMessage.showToast(
                    message: val ? StaticString.twoFactorAuthEnabled.tr : StaticString.twoFactorAuthDisabled.tr,
                  );
                },
              ),
              onTap: () {},
            ),
            _buildSettingsTile(
              iconAsset: 'assets/icons/Login history.svg',
              title: StaticString.loginHistories.tr,
              subtitle: StaticString.viewLoginActivities.tr,
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // Logout Button Row
            Center(
              child: InkWell(
                onTap: () {
                  ToastMessage.showToast(message: StaticString.loggedOut.tr);
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFEAEA),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        StaticString.logout.tr,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Version Label
            Center(
              child: Text(
                "v1.0.4",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
