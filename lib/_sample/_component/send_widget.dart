import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_sample/_sample/push_type.dart';
import 'package:flutter_local_notifications_sample/_sample/send_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class SendWidget extends StatefulWidget {
  final PushType type;
  final Function(SendModel) onTap;
  const SendWidget({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  State<SendWidget> createState() => _SendWidgetState();
}

class _SendWidgetState extends State<SendWidget> {
  final List<String> assetImages =
      List.generate(8, (i) => "assets/images/image_${i + 1}.jpg");

  late TextEditingController title;
  late TextEditingController body;
  late TextEditingController deeplink;
  late TextEditingController imageUrl;

  ValueNotifier<int?> currentImage = ValueNotifier(null);
  ValueNotifier<bool> isSubmit = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    title = TextEditingController();
    body = TextEditingController();
    deeplink = TextEditingController();
    imageUrl = TextEditingController();
  }

  Future<String?> _networkImageToFilePath(String url) async {
    try {
      final http.Response response = await http.get(Uri.parse(url));
      final Directory directory = await getTemporaryDirectory();
      final String name = "${directory.path}/${url.split('/').last}.png";
      final File file = File(name);
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _assetToFilePath() async {
    final String asset = assetImages[currentImage.value!];
    final ByteData byteData = await rootBundle.load(asset);
    final Directory directory = await getTemporaryDirectory();
    final File file = File('${directory.path}/${asset.split('/').last}');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file.path;
  }

  Future<String?> _imageToPath() async {
    int type = currentImage.value != null
        ? 1
        : imageUrl.text.trim().isNotEmpty
            ? 2
            : 0;
    return switch (type) {
      1 => await _assetToFilePath(),
      2 => await _networkImageToFilePath(imageUrl.text.trim()),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isSubmit,
        builder: (context, value, child) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              child: Stack(
                children: [
                  Column(
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
                                onTap: () async {
                                  HapticFeedback.mediumImpact();
                                  isSubmit.value = true;
                                  String? filePath = await _imageToPath();
                                  widget.onTap(
                                    SendModel(
                                      type: widget.type,
                                      title: title.text.trim().isNotEmpty
                                          ? title.text
                                          : null,
                                      body: body.text.trim().isNotEmpty
                                          ? body.text
                                          : null,
                                      deeplink: deeplink.text.trim().isNotEmpty
                                          ? deeplink.text.trim()
                                          : null,
                                      filePath: filePath,
                                    ),
                                  );
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                },
                                child: value
                                    ? const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          color: Colors.red,
                                        ),
                                      )
                                    : const Text(
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
                      _form("Deeplink", deeplink),
                      _form("URL", imageUrl),
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
                                      assetImages.length,
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
                                          margin:
                                              const EdgeInsets.only(right: 4),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color.fromRGBO(
                                                235, 235, 235, 1),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  assetImages[index],
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5,
                                                  fit: BoxFit.cover,
                                                ),
                                                if (current != null) ...[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: current != index
                                                          ? Colors.white
                                                              .withOpacity(0.8)
                                                          : null,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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
                  Visibility(
                    visible: value,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  )
                ],
              ),
            ),
          );
        });
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
