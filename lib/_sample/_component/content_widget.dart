import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/send_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/push_type.dart';
import 'package:flutter_local_notifications_sample/_sample/send_model.dart';

class ContentWidget extends StatelessWidget {
  final PushType type;
  final String content;
  final List<Widget> children;
  final Function(SendModel) onTap;
  const ContentWidget({
    super.key,
    required this.type,
    this.content = "",
    required this.children,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 48,
        margin: const EdgeInsets.only(left: 12),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              content,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                ...children,
                GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    HapticFeedback.mediumImpact();
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SendWidget(
                        onTap: onTap,
                        type: type,
                      ),
                      isScrollControlled: true,
                    );
                  },
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red,
                    ),
                    child: const Center(
                        child: Text(
                      "SEND",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white),
                    )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
