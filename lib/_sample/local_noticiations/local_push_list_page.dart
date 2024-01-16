import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/appbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/push_model.dart';

class LocalPushListPage extends StatefulWidget {
  const LocalPushListPage({super.key});

  @override
  State<LocalPushListPage> createState() => _LocalPushListPageState();
}

class _LocalPushListPageState extends State<LocalPushListPage> {
  ValueNotifier<List<PushModel>> list = ValueNotifier([]);

  bool isInit = true;

  @override
  void initState() {
    super.initState();

    _getNotifications();
    setState(() => isInit = false);
  }

  void _getNotifications() async {
    FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
    List<PendingNotificationRequest> _notifications =
        await _local.pendingNotificationRequests();
    list.value = _notifications
        .map((e) => PushModel(
            id: e.id,
            deeplink: e.payload ?? "",
            title: e.title ?? "",
            body: e.body ?? ""))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      appBar: const AppbarWidget(title: "", isLeading: true),
      body: isInit
          ? Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: kToolbarHeight + 56),
              child: const CircularProgressIndicator())
          : ValueListenableBuilder<List<PushModel>>(
              valueListenable: list,
              builder: (context, notifications, child) {
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 24),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                      child: Column(
                        children: [
                          Text(notifications[index].id.toString()),
                          Text(notifications[index].title.toString()),
                          Text(notifications[index].body.toString()),
                          Text(notifications[index].deeplink.toString()),
                        ],
                      ),
                    ),
                  ),
                );
              }),
    );
  }
}
