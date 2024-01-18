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
  final List<String> imageList = [
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/7718d102-ce66-400c-96a7-1aa125fe27a2",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/ab2f6cc0-b0cd-4f8d-aab5-478708b95de7",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/cf765bd8-98a1-4a0b-8350-0503ce80973d",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/8e9b93ba-5da4-4515-a328-0c304137028e",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/7728d053-9cbd-4f9f-ac57-b7ab4a2f0870",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/eb888572-32d7-4b7e-aff5-4a233292c45d",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/15162f40-f11b-427c-ac05-63fe1cba716a",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/bc1c33b4-6170-4ede-80ba-f083c1a13581",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/2b748179-f07b-4da2-9363-8d57910970c4",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/435e1d71-9c7d-4cc3-ae60-c078fa4026c4",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/c6babc0d-0cbe-47b7-8da6-99c06f476276",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/a64e3ead-0e95-4a37-83ef-7b493a4157c9",
    "https://github.com/boglbbogl/flutter_velog_sample/assets/75574246/736f6441-6772-49a2-8e3e-35a26a5f641e",
  ];

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
                    height: (MediaQuery.of(context).size.width / 5),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          ...List.generate(
                            imageList.length,
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        imageList[index],
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        fit: BoxFit.cover,
                                      ),
                                      if (current != null) ...[
                                        Container(
                                          decoration: BoxDecoration(
                                            color: current != index
                                                ? Colors.white.withOpacity(0.8)
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
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
