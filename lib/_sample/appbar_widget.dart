import 'package:flutter/material.dart';

class AppbarWidget extends StatelessWidget implements PreferredSize {
  final String title;
  const AppbarWidget({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget get child => throw UnimplementedError();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      centerTitle: false,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}
