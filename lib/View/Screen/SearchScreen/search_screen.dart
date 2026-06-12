import 'package:flutter/material.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/ToastMessage/toast_message.dart';
import '../../../helper/network_img/network_img.dart';

class SuggestedUser {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? initials;
  final Color? avatarBgColor;
  bool isFollowing;

  SuggestedUser({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.initials,
    this.avatarBgColor,
    this.isFollowing = false,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<SuggestedUser> _suggestedUsers = [
    SuggestedUser(
      id: '1',
      name: 'Africa',
      username: '@africa',
      avatarUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150',
    ),
    SuggestedUser(
      id: '2',
      name: 'Etinge Mabian',
      username: '@orakool',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    SuggestedUser(
      id: '3',
      name: 'Zara',
      username: '@mailla',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    ),
    SuggestedUser(
      id: '4',
      name: 'OLADEJO MUTIU DAMILARE',
      username: '@eessywealth',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    ),
    SuggestedUser(
      id: '5',
      name: 'Roy Achiambo',
      username: '@Roy',
      initials: 'RA',
      avatarBgColor: const Color(0xFF009688), // Teal/Green
    ),
    SuggestedUser(
      id: '6',
      name: 'Bezankeng Leo',
      username: '@beza90',
      initials: 'BL',
      avatarBgColor: const Color(0xFF00B0FF), // Blue/Cyan
    ),
    SuggestedUser(
      id: '7',
      name: 'Sylvester Atemnkeng Nkacha',
      username: '@Sylvester',
      initials: 'SA',
      avatarBgColor: const Color(0xFF7E57C2), // Purple
    ),
  ];

  void _toggleFollow(SuggestedUser user) {
    setState(() {
      user.isFollowing = !user.isFollowing;
    });
    if (user.isFollowing) {
      ToastMessage.showToast(message: "Started following ${user.name}");
    } else {
      ToastMessage.showToast(message: "Unfollowed ${user.name}");
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
          onPressed: () {
            // Back action
          },
        ),
        centerTitle: true,
        title: const Text(
          "Search",
          style: TextStyle(
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
                decoration: InputDecoration(
                  hintText: 'Search for people',
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
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 8.0),
            child: Text(
              "Suggested people",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
          ),
          
          // List of Suggested Users
          Expanded(
            child: ListView.separated(
              itemCount: _suggestedUsers.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFFEEEEEE),
              ),
              itemBuilder: (context, index) {
                final user = _suggestedUsers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Avatar
                      _buildAvatar(user),
                      const SizedBox(width: 12),
                      // Details (Name & Username)
                      Expanded(
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
                            user.isFollowing ? "Following" : "Follow",
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
