import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_sample/_sample/local_noticiations/local_push_list_page.dart';
import 'package:flutter_local_notifications_sample/_sample/send_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/appbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/content_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/title_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/push_model.dart';
import 'package:flutter_local_notifications_sample/_sample/push_type.dart';

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
  ValueNotifier<RepeatInterval> intervalPeriod =
      ValueNotifier(RepeatInterval.everyMinute);
  ValueNotifier<TimeOfDay> intervalDay = ValueNotifier(TimeOfDay.now());
  ValueNotifier<int> intervalWeek = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  void _onChangedWithTime() =>
      intervalPeriod.value = switch (intervalPeriod.value) {
        RepeatInterval.everyMinute => RepeatInterval.hourly,
        RepeatInterval.hourly => RepeatInterval.daily,
        RepeatInterval.daily => RepeatInterval.weekly,
        RepeatInterval.weekly => RepeatInterval.everyMinute,
      };

  void _onChangedWithDay(TimeOfDay? date) =>
      intervalDay.value = (date ?? intervalDay.value);

  void _onChangedWithWeek(int index) => intervalWeek.value = index;

  void _onChanged({
    bool isAdd = true,
  }) {
    if (!(oneTime.value == 0 && !isAdd)) {
      oneTime.value = oneTime.value + (isAdd ? 1 : -1);
    }
  }

  NotificationDetails _setDetails(
    SendModel send, {
    int maxProgress = 100,
    int progress = 0,
    bool showProgress = false,
    bool silent = false,
  }) {
    List<DarwinNotificationAttachment> attachments = [];
    StyleInformation? styleInformation;
    if (send.filePath != null) {
      attachments.add(DarwinNotificationAttachment(send.filePath!));
      styleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(send.filePath!),
      );
    }

    return NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
        attachments: attachments,
        sound: "slow_spring_board.aiff",
      ),
      android: AndroidNotificationDetails(
        send.type.channelId,
        send.type.channelName,
        channelDescription: send.type.channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: styleInformation,
        maxProgress: maxProgress,
        progress: progress,
        showProgress: showProgress,
        silent: silent,
        vibrationPattern: Int64List.fromList([0, 1500, 500, 2000, 500, 1500]),
        sound: const RawResourceAndroidNotificationSound("slow_spring_board"),
      ),
    );
  }

  Future<void> _zonedSchedule({
    tz.TZDateTime? date,
    DateTimeComponents? dateTimeComponents,
    required SendModel send,
  }) async {
    NotificationDetails details = _setDetails(send);
    tz.TZDateTime schedule = date ?? tz.TZDateTime.now(tz.local);
    PushModel data = await _setPayload(send);
    await _local.zonedSchedule(
      data.id,
      data.title,
      data.body,
      schedule,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: dateTimeComponents,
    );
  }

  Future<void> _periodicallyShow({
    required SendModel send,
  }) async {
    NotificationDetails details = _setDetails(send);
    PushModel data = await _setPayload(send);
    await _local.periodicallyShow(
      data.id,
      data.title,
      data.body,
      intervalPeriod.value,
      details,
      payload: data.deeplink,
    );
  }

  Future<void> _show({
    required SendModel send,
  }) async {
    NotificationDetails details = _setDetails(send);
    PushModel data = await _setPayload(send);
    if (oneTime.value == 0) {
      await _local.show(data.id, data.title, data.body, details,
          payload: data.deeplink);
    } else {
      tz.TZDateTime schedule =
          tz.TZDateTime.now(tz.local).add(Duration(minutes: oneTime.value));
      await _local.zonedSchedule(
        data.id,
        data.title,
        data.body,
        schedule,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  Future<void> _showWithOnlyAndroidProgress({
    required SendModel send,
  }) async {
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1), () async {
        NotificationDetails details = _setDetails(send,
            showProgress: true, progress: (i + 1) * 10, silent: true);
        PushModel data =
            await _setPayload(send, progress: "${(i + 1) * 10}/100");
        await _local.show(data.id, data.title, data.body, details,
            payload: data.deeplink);
      });
    }
  }

  tz.TZDateTime _setDate(DateTime date) {
    Duration offSet = DateTime.now().timeZoneOffset;
    DateTime local = date.add(-offSet);
    return tz.TZDateTime(tz.local, local.year, local.month, local.day,
        local.hour, local.minute, local.second);
  }

  tz.TZDateTime _setWeekDate() {
    Duration offSet = DateTime.now().timeZoneOffset;
    DateTime local = DateTime.now().add(-offSet);
    DateTime start = local.subtract(Duration(days: local.weekday - 0));
    DateTime weekDate = switch (intervalWeek.value) {
      0 => start.add(const Duration(days: 1)),
      1 => start.add(const Duration(days: 2)),
      2 => start.add(const Duration(days: 3)),
      3 => start.add(const Duration(days: 4)),
      4 => start.add(const Duration(days: 5)),
      5 => start.add(const Duration(days: 6)),
      6 => start.add(const Duration(days: 0)),
      _ => start,
    };
    return tz.TZDateTime(tz.local, weekDate.year, weekDate.month, weekDate.day,
        weekDate.hour, weekDate.minute, weekDate.second);
  }

  Future<PushModel> _setPayload(
    SendModel send, {
    tz.TZDateTime? dateTime,
    String? progress,
    int? groupId,
  }) async {
    List<PendingNotificationRequest> notifications =
        await _local.pendingNotificationRequests();
    int id = groupId ??
        (notifications.isEmpty ? 0 : notifications.map((e) => e.id).last + 1);
    String one = oneTime.value == 0 ? "즉시" : "${oneTime.value}분 후..";
    DateTime now = DateTime.now();

    String date = switch (send.type) {
      PushType.one => oneTime.value == 0
          ? _dateToString(now)
          : _dateToString(now.add(Duration(minutes: oneTime.value))),
      PushType.period => _dateToString(now),
      PushType.daily ||
      PushType.weekly ||
      PushType.montly =>
        dateTime == null ? _dateToString(now) : _dateToString(dateTime),
      _ => "",
    };
    String week = "";
    if (send.type == PushType.weekly) {
      week = switch (intervalWeek.value) {
        0 => "월",
        1 => "화",
        2 => "수",
        3 => "목",
        4 => "금",
        5 => "토",
        6 => "일",
        _ => "",
      };
    }

    PushModel data = PushModel(
      id: id,
      title: send.title ??
          switch (send.type) {
            PushType.one => "🔥 [ONE][$date] $one",
            PushType.period =>
              "🪃 [PERIOD][$date] ${intervalPeriod.value.name}",
            PushType.daily => "🌈 [DAILY] 매일 $date분 마다..",
            PushType.weekly => "💥 [WEEKLY] 매주 $week $date분 마다..",
            PushType.montly => "📅 [MONTLY] 매월 $date분 마다..",
            PushType.progressOnlyAndroid => "🧨 [PROGRESS] [$progress]",
            _ => "",
          },
      body: send.body ??
          "[TEST] flutter_local_notifications packages with Local Push\n(setting > noti)",
      deeplink: send.deeplink ??
          switch (send.type) {
            PushType.one => "tyger://flutterLocalNotifications/one",
            PushType.period => "tyger://flutterLocalNotifications/period",
            PushType.daily => "tyger://flutterLocalNotifications/daily",
            PushType.weekly => "tyger://flutterLocalNotifications/weekly",
            PushType.montly => "tyger://flutterLocalNotifications/montly",
            PushType.progressOnlyAndroid =>
              "tyger://flutterLocalNotifications/progress",
            _ => "",
          },
    );
    return data;
  }

  String _dateToString(DateTime date) =>
      "${date.hour.toString().padLeft(2, "0")}:${date.minute.toString().padLeft(2, "0")}";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
        appBar: AppbarWidget(
          title: "",
          isLeading: true,
          onAction: () async => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LocalPushListPage())),
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
                        type: PushType.one,
                        content: value == 0 ? "show" : "$value minute",
                        children: [
                          _button(Icons.remove, () => _onChanged(isAdd: false)),
                          _button(Icons.add, () => _onChanged()),
                        ],
                        onTap: (SendModel send) => _show(send: send),
                      );
                    }),
                Visibility(
                  visible: !Platform.isIOS,
                  child: ContentWidget(
                    type: PushType.progressOnlyAndroid,
                    content: "Progress Only Android",
                    children: const [],
                    onTap: (SendModel send) =>
                        _showWithOnlyAndroidProgress(send: send),
                  ),
                )
              ],
            ),
            TitleWidget(
              title: "Interval",
              children: [
                ValueListenableBuilder<RepeatInterval>(
                    valueListenable: intervalPeriod,
                    builder: (context, value, child) {
                      return ContentWidget(
                        type: PushType.period,
                        content: value.name,
                        children: [
                          _bigButton(
                              Icons.refresh, () async => _onChangedWithTime())
                        ],
                        onTap: (SendModel send) =>
                            _periodicallyShow(send: send),
                      );
                    }),
                ValueListenableBuilder<TimeOfDay>(
                    valueListenable: intervalDay,
                    builder: (context, value, child) {
                      return ContentWidget(
                        type: PushType.daily,
                        content:
                            "${value.hour.toString().padLeft(2, "0")} : ${value.minute.toString().padLeft(2, "0")}",
                        children: [
                          _bigButton(Icons.keyboard_arrow_down_rounded,
                              () async {
                            final TimeOfDay? date = await showTimePicker(
                                context: context, initialTime: value);
                            _onChangedWithDay(date);
                          })
                        ],
                        onTap: (SendModel send) => _zonedSchedule(
                          send: send,
                          date: _setDate(DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              value.hour,
                              value.minute)),
                          dateTimeComponents: DateTimeComponents.time,
                        ),
                      );
                    }),
                ValueListenableBuilder<int>(
                    valueListenable: intervalWeek,
                    builder: (context, value, child) {
                      return ContentWidget(
                        type: PushType.weekly,
                        children: [
                          ...List.generate(
                            weeks.length,
                            (index) => GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                _onChangedWithWeek(index);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                margin: EdgeInsets.only(
                                    right: index == weeks.length - 1 ? 4 : 0),
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
                        onTap: (SendModel send) => _zonedSchedule(
                          send: send,
                          date: _setWeekDate(),
                          dateTimeComponents:
                              DateTimeComponents.dayOfWeekAndTime,
                        ),
                      );
                    }),
                ContentWidget(
                  type: PushType.montly,
                  content: "Montly",
                  children: const [],
                  onTap: (SendModel send) => _zonedSchedule(
                    send: send,
                    date: _setDate(DateTime.now()),
                    dateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _bigButton(
    IconData icons,
    Function() onTap,
  ) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        height: 34,
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromRGBO(66, 66, 66, 1),
        ),
        child: Icon(
          icons,
          color: Colors.white,
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
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromRGBO(66, 66, 66, 1),
        ),
        child: Icon(
          icons,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
