import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_sample/_sample/_component/appbar_widget.dart';

class AwesomePushPage extends StatefulWidget {
  const AwesomePushPage({super.key});

  @override
  State<AwesomePushPage> createState() => _AwesomePushPageState();
}

class _AwesomePushPageState extends State<AwesomePushPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      appBar: AppbarWidget(
        isLeading: true,
        onAction: () {},
      ),
      body: ListView(
        children: [],
      ),
    );
  }
}
