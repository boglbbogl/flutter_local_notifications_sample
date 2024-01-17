import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/appbar_widget.dart';
import 'package:flutter_local_notifications_sample/_sample/push_model.dart';

class LocalPushListPage extends StatefulWidget {
  const LocalPushListPage({super.key});

  @override
  State<LocalPushListPage> createState() => _LocalPushListPageState();
}

class _LocalPushListPageState extends State<LocalPushListPage> {
  final FlutterLocalNotificationsPlugin local =
      FlutterLocalNotificationsPlugin();
  ValueNotifier<List<PushModel>> list = ValueNotifier([]);

  bool isInit = true;

  @override
  void initState() {
    super.initState();

    _getNotifications();
    setState(() => isInit = false);
  }

  void _getNotifications() async {
    List<PendingNotificationRequest> notifications =
        await local.pendingNotificationRequests();
    list.value = notifications
        .map((e) => PushModel(
              id: e.id,
              deeplink: e.payload,
              title: e.title ?? "Empty Title",
              body: e.body ?? "Empty Body",
            ))
        .toList();
  }

  void _cancelAll() {
    local.cancelAll();
    list.value = [];
  }

  void _cancelItem(int id) {
    local.cancel(id);
    list.value = List.from(list.value)..removeWhere((e) => e.id == id);
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
                if (notifications.isEmpty) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 4),
                    color: Colors.transparent,
                    child: const Text(
                      "Empty\nNotifications",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  );
                } else {
                  return ListView.builder(
                    // shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showBottom(notifications[index].id,
                            (int id) => _cancelItem(id));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 8, bottom: 40, left: 20, right: 20),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notifications[index].title.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontSize: 16),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    notifications[index].body.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(215, 215, 215, 1),
                                        fontSize: 14),
                                  ),
                                ),
                                if (notifications[index].deeplink != null) ...[
                                  Text(
                                    notifications[index].deeplink!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(215, 215, 215, 1),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                if (notifications.length - 1 == index &&
                                    notifications.length > 1) ...[
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      _cancelAll();
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(top: 40),
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: const Text(
                                        "Cancel All",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }),
    );
  }

  Future<void> _showBottom(
    int id,
    Function(int) onTap,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        height: 150,
        child: SafeArea(
          bottom: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DefaultTextStyle(
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontSize: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ID"),
                    const SizedBox(width: 12),
                    Text(id.toString()),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                  onTap(id);
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: MediaQuery.of(context).size.width - 40,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
