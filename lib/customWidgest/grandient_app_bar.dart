import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Color> gradientColors;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  GradientAppBar({
    required this.title,
    required this.gradientColors,
    this.bottom,
    this.actions
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
        title: title,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: bottom,
        actions: actions,// Add the bottom widget here
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
