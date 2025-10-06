import 'package:flutter/material.dart';
import '../utils/app_textstyles.dart';

class TakifyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  const TakifyAppBar({super.key, required this.title, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBack ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)) : null,
      title: Text(title, style: AppTextStyles.h2),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
