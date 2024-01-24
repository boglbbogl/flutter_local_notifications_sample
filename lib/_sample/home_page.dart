import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/appbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/snackbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/local_noticiations/local_push_page.dart';
import 'package:flutter_local_notifications_sample/_sample/push_type.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin local =
      FlutterLocalNotificationsPlugin();

  final ValueNotifier<bool> _isAfterMinInBackground = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionWithNotification();
    tz.initializeTimeZones();
    _initWithLocalNotifications();
    _listenerWithLocalNotifications();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _getAfterMinuteInBackground();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        _afterMinuteInBackground();
        break;
      case AppLifecycleState.resumed:
        _afterMinuteInBackgroundCancel();
      default:
        break;
    }
  }

  void _permissionWithNotification() async {
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
    }
  }

  void _initWithLocalNotifications() async {
    AndroidInitializationSettings android =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          "categoryId",
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.text("categoryInput", "Input Text",
                buttonTitle: "SEND", placeholder: "Input your text..."),
            DarwinNotificationAction.plain("categoryAccept", "Accept"),
            DarwinNotificationAction.plain("categoryDecline", "Decline"),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowSubtitle,
          },
        ),
      ],
    );

    InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    await local.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null) {
          snackbarWidget(
              context, "[Foreground / Background]", details.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  void _listenerWithLocalNotifications() async {
    NotificationAppLaunchDetails? details =
        await local.getNotificationAppLaunchDetails();
    if (details != null) {
      if (details.notificationResponse != null) {
        if (details.notificationResponse!.payload != null) {
          if (!mounted) return;
          snackbarWidget(
              context, "[Terminate]", details.notificationResponse!.payload!);
        }
      }
    }
  }

  Future<void> _getAfterMinuteInBackground() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool? value = preferences.getBool("afterMinuteInBackgroundState");
    _isAfterMinInBackground.value = value ?? false;
  }

  Future<void> _setAfterMinuteInBackground(bool value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("afterMinuteInBackgroundState", value);
  }

  void _afterMinuteInBackgroundCancel() async => await local.cancel(999999);

  void _afterMinuteInBackground() async {
    if (_isAfterMinInBackground.value) {
      await local.zonedSchedule(
          999999,
          "🚀 [AFTER] Minute In Background State",
          "[TEST] flutter_local_notifications packages with Local Push\n(setting > noti)",
          tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
          NotificationDetails(
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              badgeNumber: 1,
            ),
            android: AndroidNotificationDetails(
              PushType.afterMinInBackground.channelId,
              PushType.afterMinInBackground.channelName,
              channelDescription:
                  PushType.afterMinInBackground.channelDescription,
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: "tyger://flutterLocalNotifications/afterMinInBackground");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      appBar: const AppbarWidget(
        title: "Local Notifications",
      ),
      body: Column(
        children: [
          _button("flutter_local_notifications", const LocalPushPage()),
          Container(
            margin: const EdgeInsets.only(top: 40, bottom: 24),
            width: MediaQuery.of(context).size.width,
            height: 4,
            color: const Color.fromRGBO(96, 96, 96, 1),
          ),
          ValueListenableBuilder<bool>(
              valueListenable: _isAfterMinInBackground,
              builder: (context, value, child) {
                return Container(
                  color: Colors.transparent,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "After 1 Minute in Background",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(215, 215, 215, 1),
                        ),
                      ),
                      if (Platform.isIOS) ...[
                        CupertinoSwitch(
                          trackColor: const Color.fromRGBO(115, 115, 115, 1),
                          value: value,
                          onChanged: (bool v) async {
                            HapticFeedback.mediumImpact();
                            await _setAfterMinuteInBackground(v);
                            _isAfterMinInBackground.value = v;
                          },
                        )
                      ] else ...[
                        Switch(
                          value: value,
                          onChanged: (bool v) async {
                            HapticFeedback.mediumImpact();
                            await _setAfterMinuteInBackground(v);
                            _isAfterMinInBackground.value = v;
                          },
                        ),
                      ],
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }

  GestureDetector _button(String title, Widget widget) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => widget));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 16, bottom: 8, left: 20, right: 20),
        width: MediaQuery.of(context).size.width,
        height: 62,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
