import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppbarWidget extends StatelessWidget implements PreferredSize {
  final String? title;
  final bool isLeading;
  final Function()? onAction;
  const AppbarWidget({
    super.key,
    this.title,
    this.isLeading = false,
    this.onAction,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget get child => throw UnimplementedError();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      centerTitle: false,
      title: Text(
        title ?? "",
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      leading: isLeading
          ? GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            )
          : null,
      actions: onAction != null
          ? [
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onAction!();
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.list,
                    color: Colors.white,
                  ),
                ),
              )
            ]
          : null,
    );
  }
}
