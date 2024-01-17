import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/appbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/snackbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/awesome_notifications/awesome_push_page.dart';
import 'package:flutter_local_notifications_sample/_sample/local_noticiations/local_push_page.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin local =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _permissionWithNotification();
    _initWithLocalNotifications();
    _listenerWithLocalNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
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
          _button("awesome_notifications", const AwesomePushPage()),
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
