import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../Utils/ToastMessage/toast_message.dart';
import '../../../helper/network_img/network_img.dart';
import '../../Widgegt/ShimmerLoading/shimmer_loading.dart';
import '../../../service/api_client.dart';
import '../../../service/api_url.dart';
import '../HomeScreen/Controller/home_controller.dart';
import '../../../Core/AppRoute/app_route.dart';

class SuggestedUser {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? initials;
  final Color? avatarBgColor;
  bool isFollowing;
  final Map<String, dynamic> rawJson;

  SuggestedUser({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.initials,
    this.avatarBgColor,
    this.isFollowing = false,
    required this.rawJson,
  });

  factory SuggestedUser.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? json['username'] ?? 'Anonymous';
    final rawUsername = json['username'] ?? '';
    final usernameWithAt = rawUsername.startsWith('@') ? rawUsername : '@$rawUsername';
    final isFollowing = (Get.find<HomeController>().userFollowing['Shahriar'] ?? [])
        .any((u) => u.name.toLowerCase() == name.toLowerCase());

    // Generate initials for placeholder avatar
    String? initials;
    final parts = name.split(' ');
    if (parts.isNotEmpty) {
      initials = parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
    }

    // Pick dynamic background color
    final colors = [
      const Color(0xFF009688), // Teal
      const Color(0xFF00B0FF), // Blue/Cyan
      const Color(0xFF7E57C2), // Purple
      const Color(0xFFE57373), // Red/Pink
      const Color(0xFFFFB74D), // Orange
    ];
    final bgColor = colors[name.hashCode % colors.length];

    return SuggestedUser(
      id: (json['id'] ?? '').toString(),
      name: name,
      username: usernameWithAt,
      avatarUrl: json['photo'],
      initials: initials,
      avatarBgColor: bgColor,
      isFollowing: isFollowing,
      rawJson: json,
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<SuggestedUser> _suggestedUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isMoreUsersAvailable = true;
  bool _isLoadingMore = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _performSearch('');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _isMoreUsersAvailable) {
        _loadMoreUsers();
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    _currentQuery = query;
    _currentPage = 1;
    _isMoreUsersAvailable = true;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Get.find<ApiClient>().get(
        '${ApiUrl.searchUsers}?search=$query&per_page=10&page=1'
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final List<SuggestedUser> results = data.map((json) => SuggestedUser.fromJson(json)).toList();
          
          if (mounted) {
            setState(() {
              _suggestedUsers.clear();
              _suggestedUsers.addAll(results);
              _isLoading = false;
              if (results.length < 10) {
                _isMoreUsersAvailable = false;
              }
            });
          }
          return;
        }
      }
    } catch (e) {
      print('Search API error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await Get.find<ApiClient>().get(
        '${ApiUrl.searchUsers}?search=$_currentQuery&per_page=10&page=${_currentPage + 1}'
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          if (data.isEmpty) {
            if (mounted) {
              setState(() {
                _isMoreUsersAvailable = false;
              });
            }
          } else {
            final List<SuggestedUser> results = data.map((json) => SuggestedUser.fromJson(json)).toList();
            if (mounted) {
              setState(() {
                _suggestedUsers.addAll(results);
                _currentPage++;
                if (results.length < 10) {
                  _isMoreUsersAvailable = false;
                }
              });
            }
          }
        }
      }
    } catch (e) {
      print('Search load more error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _toggleFollow(SuggestedUser user) {
    setState(() {
      user.isFollowing = !user.isFollowing;
    });
    // Toggle follow in HomeController to keep global state in sync
    Get.find<HomeController>().toggleFollowUser(user.name);
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
          StaticString.search.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _performSearch(val.trim());
                  });
                },
                decoration: InputDecoration(
                  hintText: StaticString.searchForPeople.tr,
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
          
          // Header "Suggested people"
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 8.0),
            child: Text(
              StaticString.suggestedPeople.tr,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
          ),
          
          // List of Suggested Users
          Expanded(
            child: _isLoading
                ? ListView.separated(
                    controller: _scrollController,
                    itemCount: 6,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Color(0xFFEEEEEE),
                    ),
                    itemBuilder: (context, index) => const SearchUserShimmer(),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    itemCount: _suggestedUsers.length + (_isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Color(0xFFEEEEEE),
                    ),
                    itemBuilder: (context, index) {
                      if (index < _suggestedUsers.length) {
                        final user = _suggestedUsers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              // Avatar
                              GestureDetector(
                                onTap: () {
                                  if (user.name.toLowerCase() == 'shahriar') {
                                    Get.toNamed(AppRoute.myProfile);
                                  } else {
                                    Get.toNamed(AppRoute.profile, arguments: {
                                      'userId': user.id,
                                      'userName': user.name,
                                      'author': user.rawJson,
                                    });
                                  }
                                },
                                child: _buildAvatar(user),
                              ),
                              const SizedBox(width: 12),
                              // Details (Name & Username)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (user.name.toLowerCase() == 'shahriar') {
                                      Get.toNamed(AppRoute.myProfile);
                                    } else {
                                      Get.toNamed(AppRoute.profile, arguments: {
                                        'userId': user.id,
                                        'userName': user.name,
                                        'author': user.rawJson,
                                      });
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textLight,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        user.username,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Follow Button
                              SizedBox(
                                width: 96,
                                height: 34,
                                child: ElevatedButton(
                                  onPressed: () => _toggleFollow(user),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: user.isFollowing 
                                        ? const Color(0xFFE4E6EB) 
                                        : const Color(0xFF1877F2),
                                    foregroundColor: user.isFollowing 
                                        ? const Color(0xFF050505) 
                                        : Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                  ),
                                  child: Text(
                                    user.isFollowing ? StaticString.following.tr : StaticString.follow.tr,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(SuggestedUser user) {
    if (user.avatarUrl != null) {
      return NetworkImg(
        imageUrl: user.avatarUrl!,
        width: 48,
        height: 48,
        borderRadius: BorderRadius.circular(24),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: user.avatarBgColor ?? const Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user.initials ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
