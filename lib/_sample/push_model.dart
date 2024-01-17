class PushModel {
  final int id;
  final String? deeplink;
  final String title;
  final String body;

  const PushModel({
    required this.id,
    this.deeplink,
    required this.title,
    required this.body,
  });

  @override
  String toString() =>
      "PushModel(id: $id, title: $title, body: $body, deeplink: $deeplink)";
}
