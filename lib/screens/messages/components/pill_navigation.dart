import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../profile/ProfileScreen.dart';

class PillScreen extends StatefulWidget {
  final List<Widget> screens;
  final String title;

  const PillScreen({
    super.key,
    required this.screens,
    required this.title,
  });

  @override
  State<PillScreen> createState() => _PillScreenState();
}

class _PillScreenState extends State<PillScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Map<String, dynamic>> items = [
    {"icon": Icons.chat_bubble, "label": "Chats"},
    {"icon": Icons.hexagon_rounded, "label": "Nodes"},
    {"icon": Icons.blur_circular_outlined, "label": "Calls"},
    {"icon": Icons.notifications, "label": "Alerts"},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBackground,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            children: widget.screens,
          ),
          _buildFadeOverlay(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(child: _buildBottomNavigationBar()),
          ),
        ],
      ),
    );
  }

  Widget _buildFadeOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 150,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [kDarkBackground.withOpacity(1), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPillNav(),
          const SizedBox(width: 16),
          _buildProfileIcon(context), // profile button back in row
        ],
      ),
    );
  }

  Widget _buildPillNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.black.withOpacity(0.15),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: kItemBackground.withOpacity(0.1),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (index) {
              final isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryColor.withOpacity(0.2) : Colors
                        .transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    items[index]["icon"] as IconData,
                    size: 24,
                    color: isSelected ? kPrimaryColor : Colors.grey,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Go to the ProfileUI page (last one in screens list)
        final profilePageIndex = widget.screens.length - 1;
        _onItemTapped(profilePageIndex);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              color: kItemBackground,
            ),
            child: const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage("assets/images/user_2.png"),
            ),
          ),
        ),
      ),
    );
  }
}
