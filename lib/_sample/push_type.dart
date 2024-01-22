enum PushType {
  one(
    channelId: "onlyOne",
    channelName: "onlyOne",
    channelDescription: "Test notifictions with only one",
  ),
  progressOnlyAndroid(
    channelId: "progressOnlyAndroid",
    channelName: "progressOnlyAndroid",
    channelDescription: "Test notifications with Only progress",
  ),
  period(
    channelId: "intervalPeriod",
    channelName: "intervalPeriod",
    channelDescription: "Test notifictions with time interval period",
  ),
  daily(
    channelId: "daily",
    channelName: "daily",
    channelDescription: "Test notifictions with daily",
  ),
  weekly(
    channelId: "weekly",
    channelName: "weekly",
    channelDescription: "Test notifictions with weekly",
  ),
  montly(
    channelId: "montly",
    channelName: "montly",
    channelDescription: "Test noticiations with montly",
  ),
  afterMinInBackground(
    channelId: "afterInBackground",
    channelName: "afterInBackground",
    channelDescription: "Test noticiations with After Minute In Background",
  );

  final String channelId;
  final String channelName;
  final String channelDescription;

  const PushType({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
  });
}
