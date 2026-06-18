import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../HomeScreen/Controller/home_controller.dart';
import '../../../helper/network_img/network_img.dart';
import '../../../service/api_client.dart';
import '../../../service/api_url.dart';

class TagFriendsScreen extends StatefulWidget {
  const TagFriendsScreen({super.key});

  @override
  State<TagFriendsScreen> createState() => _TagFriendsScreenState();
}

class _TagFriendsScreenState extends State<TagFriendsScreen> {
  final HomeController _homeController = Get.find<HomeController>();
  final ApiClient _apiClient = Get.find<ApiClient>();
  final List<String> _selectedFriends = [];
  List<FollowerModel> _allFollowers = [];
  List<FollowerModel> _filteredFriends = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFriends);

    // Preload selected friends from arguments
    if (Get.arguments != null && Get.arguments is List<String>) {
      _selectedFriends.addAll(Get.arguments as List<String>);
    }

    _fetchFollowers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFriends);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFollowers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiClient.get(ApiUrl.followers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic responseData = jsonDecode(response.body);
        List<dynamic> dataList = [];
        if (responseData is Map && responseData.containsKey('data') && responseData['data'] is List) {
          dataList = responseData['data'];
        } else if (responseData is List) {
          dataList = responseData;
        }

        final List<FollowerModel> loaded = dataList.map((json) {
          final id = (json['id'] ?? '').toString();
          final name = json['name'] ?? json['username'] ?? json['user_name'] ?? 'Anonymous';
          final photo = json['photo'] ?? json['photo_url'] ?? json['avatar'] ?? json['avatar_url'] ?? json['image'] ?? '';
          return FollowerModel(
            id: id,
            name: name,
            avatarUrl: photo,
            rawJson: json is Map<String, dynamic> ? json : null,
          );
        }).toList();

        setState(() {
          _allFollowers = loaded;
          _filteredFriends = loaded;
        });
      }
    } catch (e) {
      debugPrint('Error fetching followers in TagFriendsScreen: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = List.from(_allFollowers);
      } else {
        _filteredFriends = _allFollowers
            .where((f) => f.name.toLowerCase().contains(query))
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
          StaticString.tagFriends.tr,
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
                    hintText: StaticString.searchFriends.tr,
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

            // Followers List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
                      ),
                    )
                  : _filteredFriends.isEmpty
                      ? Center(
                          child: Text(
                            StaticString.noFriendsFound.tr,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredFriends.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Color(0xFFEEEEEE),
                      ),
                      itemBuilder: (context, index) {
                        final friend = _filteredFriends[index];
                        final isSelected = _selectedFriends.contains(friend.name);

                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xFF1877F2),
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          secondary: NetworkImg(
                            imageUrl: friend.avatarUrl,
                            width: 44,
                            height: 44,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          title: Text(
                            friend.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                          value: isSelected,
                          onChanged: (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                if (!_selectedFriends.contains(friend.name)) {
                                  _selectedFriends.add(friend.name);
                                }
                              } else {
                                _selectedFriends.remove(friend.name);
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
                    Get.back(result: _selectedFriends);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
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
