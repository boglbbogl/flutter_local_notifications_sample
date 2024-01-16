import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/appbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/content_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/title_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/push_type.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation("Asia/Seoul"));
    _initialization();
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

  NotificationDetails _setDetails(PushType type) {
    return NotificationDetails(
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
  }

  Future<void> _zonedSchedule({
    required PushType type,
    required String title,
    required String body,
    tz.TZDateTime? date,
    DateTimeComponents? dateTimeComponents,
  }) async {
    NotificationDetails details = _setDetails(type);
    tz.TZDateTime schedule = date ?? tz.TZDateTime.now(tz.local);
    await _local.zonedSchedule(
      type.id,
      title,
      body,
      schedule,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: dateTimeComponents,
    );
  }

  Future<void> _periodicallyShow({
    required PushType type,
    required String title,
    required String body,
  }) async {
    NotificationDetails details = _setDetails(type);
    await _local.periodicallyShow(
      type.id,
      title,
      body,
      intervalPeriod.value,
      details,
      payload: type.deeplink,
    );
  }

  Future<void> _show({
    required PushType type,
    required String title,
    required String body,
  }) async {
    NotificationDetails details = _setDetails(type);

    if (oneTime.value == 0) {
      await _local.show(type.id, title, body, details, payload: type.deeplink);
    } else {
      tz.TZDateTime schedule =
          tz.TZDateTime.now(tz.local).add(Duration(minutes: oneTime.value));
      await _zonedSchedule(
        type: type,
        title: title,
        body: body,
        date: schedule,
        dateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
    _setDate(DateTime.now());
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
        appBar: AppbarWidget(
          title: "",
          isLeading: true,
          onAction: () async {
            List<PendingNotificationRequest> _notifications =
                await _local.pendingNotificationRequests();
            for (final e in _notifications) {
              print(e.title);
              print(e.body);
              print(e.payload);
              print(e.id);
            }
          },
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
                        onTap: (String title, String body) => _periodicallyShow(
                            type: PushType.period, title: title, body: body),
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
                        onTap: (String title, String body) => _zonedSchedule(
                          type: PushType.daily,
                          title: title,
                          body: body,
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
                        onTap: (String title, String body) => _zonedSchedule(
                          type: PushType.weekly,
                          title: title,
                          body: body,
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
                  onTap: (String title, String body) => _zonedSchedule(
                    type: PushType.montly,
                    title: title,
                    body: body,
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
