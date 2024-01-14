import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const TitleWidget({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
