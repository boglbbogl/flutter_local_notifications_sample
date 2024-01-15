import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_sample/_sample/push_type.dart';

class SettingWidget extends StatefulWidget {
  final PushType type;
  final Function(String, String) onTap;
  const SettingWidget({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  late TextEditingController title;

  late TextEditingController body;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.type.title);
    body = TextEditingController(text: widget.type.body);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                  top: 32, left: 12, right: 12, bottom: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        widget.onTap(title.text, body.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "SEND",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _form("title", title),
            _form("body", body),
          ],
        ),
      ),
    );
  }

  Container _form(
    String title,
    TextEditingController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(115, 115, 115, 1),
              fontSize: 18,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 3,
                  color: const Color.fromRGBO(115, 115, 115, 1),
                )),
            child: TextFormField(
              controller: controller,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
