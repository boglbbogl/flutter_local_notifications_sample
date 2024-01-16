enum PushType {
  one(
    id: 0,
    channelId: "onlyOne",
    channelName: "onlyOne",
    channelDescription: "Test notifictions with only one",
    deeplink: "tyger://",
    title: "🌈 [TEST] Noticiaionts with only one",
    body:
        "Noticiations send test with flutter_local_notifications ✨ \n(setting > notification)",
  ),
  period(
    id: 1,
    channelId: "intervalPeriod",
    channelName: "intervalPeriod",
    channelDescription: "Test notifictions with time interval period",
    deeplink: "tyger://",
    title: "🔥 [TEST] Noticiaionts with only period",
    body:
        "Noticiations send test with flutter_local_notifications ✨ \n(setting > notification)",
  ),
  daily(
    id: 2,
    channelId: "daily",
    channelName: "daily",
    channelDescription: "Test notifictions with daily",
    deeplink: "tyger://",
    title: "💧 [TEST] Noticiaionts with only daily",
    body:
        "Noticiations send test with flutter_local_notifications ✨ \n(setting > notification)",
  ),
  weekly(
    id: 3,
    channelId: "weekly",
    channelName: "weekly",
    channelDescription: "Test notifictions with weekly",
    deeplink: "tyger://",
    title: "💬 [TEST] Noticiaionts with only weekly",
    body:
        "Noticiations send test with flutter_local_notifications ✨ \n(setting > notification)",
  ),
  montly(
    id: 4,
    channelId: "montly",
    channelName: "montly",
    channelDescription: "Test noticiations with montly",
    deeplink: "tyger://",
    title: "📅 [TEST] Noticiaionts with only montly",
    body:
        "Noticiations send test with flutter_local_notifications ✨ \n(setting > notification)",
  );

  final int id;
  final String channelId;
  final String channelName;
  final String channelDescription;
  final String deeplink;
  final String title;
  final String body;

  const PushType({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.deeplink,
    required this.title,
    required this.body,
  });
}
