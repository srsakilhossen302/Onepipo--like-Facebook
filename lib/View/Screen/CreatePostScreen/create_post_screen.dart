import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Core/AppRoute/app_route.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../Utils/ToastMessage/toast_message.dart';
import '../HomeScreen/Controller/home_controller.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final HomeController _homeController = Get.find<HomeController>();
  String _selectedPostType = 'solution'; // Default to match screenshot
  int _wordCount = 0;
  int? _editingPostIndex;

  // Selection states
  String? _selectedImagePath;
  String? _selectedGroupName;
  final List<String> _selectedTaggedFriends = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateWordCount);
    
    // Check if we are editing an existing post
    if (Get.arguments != null && Get.arguments is int) {
      _editingPostIndex = Get.arguments as int;
      final post = _homeController.posts[_editingPostIndex!];
      _textController.text = post.contentText;
      _selectedPostType = post.badgeText;
      _selectedImagePath = post.contentImageUrl;
      _selectedGroupName = post.groupName;
      if (post.taggedFriends != null) {
        _selectedTaggedFriends.addAll(post.taggedFriends!);
      }
      _updateWordCount();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_updateWordCount);
    _textController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _wordCount = 0;
      });
      return;
    }
    setState(() {
      _wordCount = text.split(RegExp(r'\s+')).length;
    });
  }

  void _handlePostSubmit() async {
    if (_textController.text.trim().isEmpty && _selectedImagePath == null) return;
    if (_wordCount > 350) {
      ToastMessage.showToast(message: StaticString.wordLimitExceeded.tr);
      return;
    }

    bool success = false;
    if (_editingPostIndex != null) {
      success = await _homeController.updatePost(
        _editingPostIndex!,
        _textController.text,
        _selectedPostType,
        groupName: _selectedGroupName,
        taggedFriends: _selectedTaggedFriends.isEmpty ? null : _selectedTaggedFriends,
        contentImageUrl: _selectedImagePath,
      );
    } else {
      success = await _homeController.addNewPost(
        _textController.text,
        _selectedPostType,
        groupName: _selectedGroupName,
        taggedFriends: _selectedTaggedFriends.isEmpty ? null : _selectedTaggedFriends,
        contentImageUrl: _selectedImagePath,
      );
    }

    if (success) {
      Get.back();
    }
  }

  Widget _buildPostTypeRadio(String label, String value) {
    final isSelected = _selectedPostType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPostType = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
              border: Border.all(
                color: isSelected ? const Color(0xFF1877F2) : Colors.grey,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPostEnabled = (_textController.text.trim().isNotEmpty || _selectedImagePath != null) && _wordCount <= 350;

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
          _editingPostIndex != null ? StaticString.editPost.tr : StaticString.createPost.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        actions: [
          Obx(() {
            final isPostEnabled = (_textController.text.trim().isNotEmpty || _selectedImagePath != null) && _wordCount <= 350;
            final isSaving = _homeController.isLoading.value;
            return TextButton(
              onPressed: (isPostEnabled && !isSaving) ? _handlePostSubmit : null,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
                      ),
                    )
                  : Text(
                      _editingPostIndex != null ? StaticString.save.tr : StaticString.post.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPostEnabled ? const Color(0xFF1877F2) : Colors.grey[400],
                      ),
                    ),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Row
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2F3F5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textLight,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "Shahriar",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (_selectedGroupName != null) ...[
                                      const TextSpan(
                                        text: " ▶ ",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _selectedGroupName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1877F2),
                                        ),
                                      ),
                                    ],
                                    if (_selectedTaggedFriends.isNotEmpty) ...[
                                      TextSpan(
                                        text: " ${StaticString.isWith.tr} ",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _selectedTaggedFriends.join(', '),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "@shahriar_",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Public Dropdown Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.public_rounded,
                                size: 14,
                                color: Color(0xFF65676B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                StaticString.public.tr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF65676B),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Multi-line Text Editor
                    TextField(
                      controller: _textController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: AppColors.textLight,
                      ),
                      decoration: InputDecoration(
                        hintText: StaticString.shareThoughtsHint.tr,
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                      ),
                    ),

                    if (_selectedImagePath != null) ...[
                      const SizedBox(height: 12),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _selectedImagePath!.startsWith('http')
                                  ? Image.network(
                                      _selectedImagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 50),
                                    )
                                  : Image.file(
                                      File(_selectedImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImagePath = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Max words hint
                    Text(
                      "${StaticString.maxWordsHint.tr}${_wordCount > 0 ? ' ($_wordCount/350)' : ''}",
                      style: TextStyle(
                        color: _wordCount > 350 ? Colors.red : Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Area: Post type selection & Toolbar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFEEEEEE),
                    width: 0.8,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Post Type Selection Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Text(
                          StaticString.postTypeLabel.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        _buildPostTypeRadio(StaticString.problem.tr, "problem"),
                        const SizedBox(width: 24),
                        _buildPostTypeRadio(StaticString.solution.tr, "solution"),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),

                  // Toolbar with Gallery, Groups, Tag buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.image_outlined,
                          color: _selectedImagePath != null ? Colors.white : const Color(0xFF04070D),
                          backgroundColor: _selectedImagePath != null ? const Color(0xFF1877F2) : const Color(0xFFE4F0EC),
                          onTap: () async {
                            try {
                              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                setState(() {
                                  _selectedImagePath = image.path;
                                });
                              }
                            } catch (e) {
                              ToastMessage.showToast(message: "Failed to open gallery: $e");
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.people_outline_rounded,
                          color: _selectedGroupName != null ? Colors.white : const Color(0xFF04070D),
                          backgroundColor: _selectedGroupName != null ? const Color(0xFF1877F2) : const Color(0xFFE1F0FC),
                          onTap: () async {
                            final result = await Get.toNamed(
                              AppRoute.groupSelection,
                              arguments: _selectedGroupName,
                            );
                            if (result != null || result == null) {
                              setState(() {
                                _selectedGroupName = result as String?;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.local_offer_outlined,
                          color: _selectedTaggedFriends.isNotEmpty ? Colors.white : const Color(0xFF04070D),
                          backgroundColor: _selectedTaggedFriends.isNotEmpty ? const Color(0xFF1877F2) : const Color(0xFFE1F5EC),
                          onTap: () async {
                            final result = await Get.toNamed(
                              AppRoute.tagFriends,
                              arguments: List<String>.from(_selectedTaggedFriends),
                            );
                            if (result != null) {
                              setState(() {
                                _selectedTaggedFriends.clear();
                                _selectedTaggedFriends.addAll(result as List<String>);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
