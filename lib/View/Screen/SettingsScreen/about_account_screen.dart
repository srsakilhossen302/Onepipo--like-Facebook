import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../helper/shared_prefe/shared_prefe.dart';

class AboutAccountScreen extends StatefulWidget {
  const AboutAccountScreen({super.key});

  @override
  State<AboutAccountScreen> createState() => _AboutAccountScreenState();
}

class _AboutAccountScreenState extends State<AboutAccountScreen> {
  String _memberSinceText = 'May 2026';

  @override
  void initState() {
    super.initState();
    _loadMemberSinceDate();
  }

  void _loadMemberSinceDate() {
    String dateStr = '';
    if (Get.isRegistered<SharedPreferenceHelper>()) {
      dateStr = Get.find<SharedPreferenceHelper>().getUserCreatedAt();
    }

    if (dateStr.isNotEmpty) {
      final formatted = _formatMonthYear(dateStr);
      if (formatted.isNotEmpty) {
        setState(() {
          _memberSinceText = formatted;
        });
      }
    }
  }

  String _formatMonthYear(String input) {
    try {
      DateTime? dt = DateTime.tryParse(input);
      if (dt != null) {
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        return "${months[dt.month - 1]} ${dt.year}";
      }
    } catch (_) {}
    return '';
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
          StaticString.aboutAccount.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Member since',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _memberSinceText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B64D3),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
