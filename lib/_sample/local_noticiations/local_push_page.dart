import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/appbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/content_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/title_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/content_type.dart';

class LocalPushPage extends StatefulWidget {
  const LocalPushPage({super.key});

  @override
  State<LocalPushPage> createState() => _LocalPushPageState();
}

class _LocalPushPageState extends State<LocalPushPage> {
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final List<String> weeks = ["M", "T", "W", "T", "F", "S", "S"];

  ValueNotifier<int> oneTime = ValueNotifier(0);
  ValueNotifier<int> intervalTime = ValueNotifier(1);
  ValueNotifier<TimeOfDay> intervalDay = ValueNotifier(TimeOfDay.now());
  ValueNotifier<int> intervalWeek = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _initialization();
  }

  void _onChangedWithDay(TimeOfDay? date) =>
      intervalDay.value = (date ?? intervalDay.value);

  void _onChangedWithWeek(int index) => intervalWeek.value = index;

  void _onChanged({
    required int type,
    bool isAdd = true,
  }) {
    switch (type) {
      case 0:
        if (oneTime.value == 0 && !isAdd) {
          break;
        } else {
          oneTime.value = oneTime.value + (isAdd ? 1 : -1);
        }
        break;
      case 1:
        if (intervalTime.value == 1 && !isAdd) {
          break;
        } else {
          intervalTime.value = intervalTime.value + (isAdd ? 1 : -1);
        }
        break;
      default:
        break;
    }
  }

  void _initialization() async {
    AndroidInitializationSettings android =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    await _local.initialize(settings);
  }

  Future<void> _show({
    required PushType type,
    required String title,
    required String body,
  }) async {
    NotificationDetails details = NotificationDetails(
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      ),
      android: AndroidNotificationDetails(
        type.channelId,
        type.channelName,
        channelDescription: type.channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    // if(oneTime.value )
    await _local.show(
      type.id,
      title,
      body,
      details,
      payload: "tyger://",
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
        appBar: const AppbarWidget(
          title: "",
          isLeading: true,
        ),
        body: ListView(
          children: [
            TitleWidget(
              title: "Only One",
              children: [
                ValueListenableBuilder<int>(
                    valueListenable: oneTime,
                    builder: (context, value, child) {
                      return ContentWidget(
                        content: value == 0 ? "show" : "$value minute",
                        children: [
                          _button(Icons.remove,
                              () => _onChanged(type: 0, isAdd: false)),
                          _button(Icons.add, () => _onChanged(type: 0)),
                        ],
                        onTap: (String title, String body) => _show(
                          type: PushType.one,
                          title: title,
                          body: body,
                        ),
                      );
                    }),
              ],
            ),
            TitleWidget(
              title: "Interval",
              children: [
                ValueListenableBuilder<int>(
                    valueListenable: intervalTime,
                    builder: (context, value, child) {
                      return ContentWidget(
                        content: "$value minute",
                        children: [
                          _button(Icons.remove,
                              () => _onChanged(type: 1, isAdd: false)),
                          _button(Icons.add, () => _onChanged(type: 1)),
                        ],
                        onTap: (String title, String body) => null,
                      );
                    }),
                ValueListenableBuilder<TimeOfDay>(
                    valueListenable: intervalDay,
                    builder: (context, value, child) {
                      return ContentWidget(
                        content:
                            "${value.hour.toString().padLeft(2, "0")} : ${value.minute.toString().padLeft(2, "0")}",
                        children: [
                          GestureDetector(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              final TimeOfDay? date = await showTimePicker(
                                  context: context, initialTime: value);
                              _onChangedWithDay(date);
                            },
                            child: Container(
                              height: 32,
                              margin: const EdgeInsets.only(right: 4),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 22),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color.fromRGBO(66, 66, 66, 1),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        onTap: (String title, String body) => null,
                      );
                    }),
                ValueListenableBuilder<int>(
                    valueListenable: intervalWeek,
                    builder: (context, value, child) {
                      return ContentWidget(
                        children: [
                          ...List.generate(
                            weeks.length,
                            (index) => GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                _onChangedWithWeek(index);
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                    color: index == value ? Colors.amber : null,
                                    border: Border.all(
                                      color: index == value
                                          ? Colors.amber
                                          : const Color.fromRGBO(
                                              155, 155, 155, 1),
                                    )),
                                child: Center(
                                  child: Text(
                                    weeks[index],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: index == value
                                            ? Colors.white
                                            : const Color.fromRGBO(
                                                155, 155, 155, 1)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        onTap: (String title, String body) => null,
                      );
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _button(
    IconData icons,
    Function() onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromRGBO(66, 66, 66, 1),
        ),
        child: Icon(
          icons,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
