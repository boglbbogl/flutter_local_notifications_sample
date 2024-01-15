enum PushType {
  one(
    id: 0,
    channelId: "onlyOne",
    channelName: "onlyOne",
    channelDescription: "Test notifictions with only one",
    deeplink: "tyger://",
  ),
  minute(
    id: 1,
    channelId: "intervalTime",
    channelName: "intervalTime",
    channelDescription: "Test notifictions with time interval",
    deeplink: "tyger://",
  ),
  daily(
    id: 2,
    channelId: "daily",
    channelName: "daily",
    channelDescription: "Test notifictions with daily",
    deeplink: "tyger://",
  ),
  weekly(
    id: 3,
    channelId: "weekly",
    channelName: "weekly",
    channelDescription: "Test notifictions with weekly",
    deeplink: "tyger://",
  );

  final int id;
  final String channelId;
  final String channelName;
  final String channelDescription;
  final String deeplink;

  const PushType({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.deeplink,
  });
}
