import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const barHeight = 62.0;
    const protrusion = 16.0;

    return SizedBox(
      height: barHeight + protrusion + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: barHeight + bottomPadding,
              padding: EdgeInsets.only(bottom: bottomPadding),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFEEEEEE),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildNavItem(
                      index: 0,
                      iconAsset: 'assets/icons/Feed-Icons.svg',
                      label: 'Feed',
                      isActive: currentIndex == 0,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 1,
                      iconAsset: 'assets/icons/Notification-icons.svg',
                      label: 'Alerts',
                      isActive: currentIndex == 1,
                    ),
                  ),
                  const Expanded(
                    child: SizedBox.shrink(),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 2,
                      iconAsset: 'assets/icons/Search-icons.svg',
                      label: 'Search',
                      isActive: currentIndex == 2,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 3,
                      iconAsset: 'assets/icons/Settings-icons.svg',
                      label: 'Settings',
                      isActive: currentIndex == 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating Center Button
          Positioned(
            top: 2,
            left: 0,
            right: 0,
            child: Center(
              child: _buildCenterAddButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconAsset,
    required String label,
    required bool isActive,
  }) {
    const activeColor = Color(0xFF1877F2);
    const inactiveColor = Color(0xFF8E8E93);
    final color = isActive ? activeColor : inactiveColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1877F2).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFF1877F2),
        type: MaterialType.circle,
        child: InkWell(
          onTap: onAddTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 54,
            height: 54,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
