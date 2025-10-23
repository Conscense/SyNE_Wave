import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../constants.dart';

enum PillBarState {
  main,
  search,
}

class TopPillBar extends StatefulWidget implements PreferredSizeWidget {
  final PillBarState state;
  final double maxHeight;
  final double minHeight;
  final bool scrollShrink;
  final ScrollController? scrollController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchActivated;
  final ValueChanged<int>? onTabChanged; // Tabs: 0 = Recents, 1 = Requests

  const TopPillBar({
    super.key,
    required this.state,
    this.maxHeight = 120,
    this.minHeight = 60,
    this.scrollShrink = false,
    this.scrollController,
    this.onSearchChanged,
    this.onSearchActivated,
    this.onTabChanged,
  });

  @override
  State<TopPillBar> createState() => _TopPillBarState();

  @override
  Size get preferredSize => Size.fromHeight(maxHeight);
}

class _TopPillBarState extends State<TopPillBar> {
  double currentHeight = 0;
  late PillBarState _state;
  late TextEditingController _searchController;
  bool isTyping = false;
  int selectedTab = 0; // 0 = Recents, 1 = Requests

  @override
  void initState() {
    super.initState();
    currentHeight = widget.maxHeight;
    _state = widget.state;
    _searchController = TextEditingController();

    if (widget.scrollShrink && widget.scrollController != null) {
      widget.scrollController!.addListener(_handleScroll);
    }
  }

  void _handleScroll() {
    final offset = widget.scrollController!.offset;
    setState(() {
      currentHeight =
          (widget.maxHeight - offset).clamp(widget.minHeight, widget.maxHeight);
    });
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_handleScroll);
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildMainTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => selectedTab = 0);
            widget.onTabChanged?.call(0);
          },
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: selectedTab == 0 ? 1.0 : 0.5,
            child: const Text(
              "Recents",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
        GestureDetector(
          onTap: () {
            setState(() => selectedTab = 1);
            widget.onTabChanged?.call(1);
          },
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: selectedTab == 1 ? 1.0 : 0.5,
            child: const Text(
              "Requests",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchUI() {
    return Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isTyping
                ? Row(
              key: const ValueKey("field"),
              children: [
                const Icon(Icons.search, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: widget.onSearchChanged,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Search Chats...",
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            )
                : GestureDetector(
              key: const ValueKey("label"),
              onTap: () {
                setState(() => isTyping = true);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.search, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Search Chats...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isTyping)
          GestureDetector(
            onTap: () {
              setState(() {
                _searchController.clear();
                widget.onSearchChanged?.call('');
                isTyping = false;
              });
            },
            child: const Icon(Icons.close, color: Colors.white),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: currentHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kItemBackground,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.6),
                  Colors.black.withOpacity(0.2),
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
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: _state == PillBarState.main
                      ? _buildMainTabs()
                      : _buildSearchUI(),
                ),
                if (_state == PillBarState.main)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _state = PillBarState.search;
                          isTyping = true;
                        });
                        widget.onSearchActivated?.call();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(currentHeight);
}
