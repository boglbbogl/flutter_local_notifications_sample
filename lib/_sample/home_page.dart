import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/appbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/awesome_notifications/awesome_push_page.dart';
import 'package:flutter_local_notifications_sample/_sample/local_noticiations/local_push_page.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _permissionWithNotification();
  }

  void _permissionWithNotification() async {
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
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
