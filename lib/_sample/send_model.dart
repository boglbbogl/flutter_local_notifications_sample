import 'package:flutter_local_notifications_sample/_sample/push_type.dart';

class SendModel {
  final PushType type;
  final String? title;
  final String? body;
  final String? deeplink;
  final String? filePath;

  const SendModel({
    required this.type,
    required this.title,
    required this.body,
    required this.deeplink,
    required this.filePath,
  });
}
