import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final List<String> _allGroups = [
    'Flutter Developers',
    'Onepipo Community',
    'Tech Enthusiasts',
    'Dhaka University Friends',
    'Creative Designers',
    'Freelancers Bangladesh',
    'Social Network Admins',
  ];

  List<String> _filteredGroups = [];
  String? _selectedGroupName;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredGroups = List.from(_allGroups);
    _searchController.addListener(_filterGroups);
    
    // If a group was already selected, preload it from arguments
    if (Get.arguments != null && Get.arguments is String) {
      _selectedGroupName = Get.arguments as String;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterGroups);
    _searchController.dispose();
    super.dispose();
  }

  void _filterGroups() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredGroups = List.from(_allGroups);
      } else {
        _filteredGroups = _allGroups
            .where((g) => g.toLowerCase().contains(query))
            .toList();
      }
    });
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
          StaticString.selectGroup.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
            // Search Input Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: StaticString.searchGroup.tr,
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14.5,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey[600],
                      size: 22,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF1877F2),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Groups List
            Expanded(
              child: _filteredGroups.isEmpty
                  ? Center(
                      child: Text(
                        StaticString.noGroupsFound.tr,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredGroups.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Color(0xFFEEEEEE),
                      ),
                      itemBuilder: (context, index) {
                        final groupName = _filteredGroups[index];
                        final isSelected = _selectedGroupName == groupName;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? const Color(0xFFE1F0FC)
                                : const Color(0xFFF0F2F5),
                            child: Icon(
                              Icons.groups_rounded,
                              color: isSelected
                                  ? const Color(0xFF1877F2)
                                  : Colors.grey[700],
                            ),
                          ),
                          title: Text(
                            groupName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? const Color(0xFF1877F2) : AppColors.textLight,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF1877F2),
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedGroupName = null; // Unselect
                              } else {
                                _selectedGroupName = groupName;
                              }
                            });
                          },
                        );
                      },
                    ),
            ),

            // Next / Done Button Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(result: _selectedGroupName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    StaticString.next.tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
