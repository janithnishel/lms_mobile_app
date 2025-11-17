// lib/widgets/shared/search_bar_sliver.dart

import 'package:flutter/material.dart';
import 'package:lms_app/widgets/shared/search_bar.dart';
// Import your CustomSearchBar

// ----------------------------------------------------
// SliverPersistentHeaderDelegate (to pin the Search Bar)
// ----------------------------------------------------

class SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  // ... (minHeight, maxHeight properties මෙහිදී වෙනස් වේ)
  final double minHeight = 70.0;
  final double maxHeight = 70.0;

  SearchHeaderDelegate({required this.child});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Added background and padding to the Search Bar
    return Container(
      color: Colors.grey[100], // 💡 Screen background color
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: child, // ⬅️ මෙතැනට CustomSearchBar එක එයි
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

// ----------------------------------------------------
// SearchBarSliver Widget (Child for pinned header)
// ----------------------------------------------------

class SearchBarSliver extends StatelessWidget {
  const SearchBarSliver({super.key});

  @override
  Widget build(BuildContext context) {
    // Uses CustomSearchBar here.
    return const CustomSearchBar(
      hintText: 'Search ICT A-Level videos...', // Put the necessary Hint Text
    );
  }
}
