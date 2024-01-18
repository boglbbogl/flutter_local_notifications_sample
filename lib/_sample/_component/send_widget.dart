import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_sample/_sample/push_type.dart';

class SendWidget extends StatefulWidget {
  final PushType type;
  final Function(String?, String?, String?) onTap;
  const SendWidget({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  State<SendWidget> createState() => _SendWidgetState();
}

class _SendWidgetState extends State<SendWidget> {
  final List<String> imageList = [];

  late TextEditingController title;
  late TextEditingController body;
  late TextEditingController deeplink;
  late TextEditingController imageUrl;

  ValueNotifier<int?> currentImage = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    title = TextEditingController();
    body = TextEditingController();
    deeplink = TextEditingController();
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
                        widget.onTap(
                          title.text.trim().isNotEmpty ? title.text : null,
                          body.text.trim().isNotEmpty ? body.text : null,
                          deeplink.text.trim().isNotEmpty
                              ? deeplink.text.trim()
                              : null,
                        );
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
            _form("Title", title),
            _form("Body", body),
            _form("Deeplink", body),
            _form("URL", body),
            ValueListenableBuilder(
                valueListenable: currentImage,
                builder: (context, current, child) {
                  return Container(
                    margin: const EdgeInsets.only(top: 12),
                    height: 100,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          ...List.generate(
                            20,
                            (index) => GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                if (currentImage.value == index) {
                                  currentImage.value = null;
                                } else {
                                  currentImage.value = index;
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: MediaQuery.of(context).size.width / 5,
                                height: MediaQuery.of(context).size.width / 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color.fromRGBO(235, 235, 235, 1),
                                ),
                                child: Stack(
                                  children: [
                                    if (current == index) ...[
                                      Container(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.check,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              7,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  );
                }),
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
