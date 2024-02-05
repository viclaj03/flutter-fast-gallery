import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Color> gradientColors;
  final PreferredSizeWidget? bottom;

  GradientAppBar({
    required this.title,
    required this.gradientColors,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: bottom, // Add the bottom widget here
      ),
    );
  }

  @override
  Size get preferredSize {
    // Calculate preferred size including the height of the bottom widget
    double appBarHeight = kToolbarHeight + (bottom?.preferredSize.height ?? 0);
    return Size.fromHeight(appBarHeight);
  }
}
