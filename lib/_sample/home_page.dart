import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_sample/_sample/appbar_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _permissionWithNotification();
    _initialization();
  }

  void _permissionWithNotification() async {
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
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

  Future<void> _show() async {
    NotificationDetails details = const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      ),
      android: AndroidNotificationDetails(
        "show_test",
        "show_test",
        channelDescription: "Test Local notications",
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await _local.show(
      0,
      "타이틀이 보여지는 영역입니다.",
      "컨텐츠 내용이 보여지는 영역입니다.\ntest show()",
      details,
      payload: "tyger://",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarWidget(
        title: "Local Notifications",
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () async => _show(),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
