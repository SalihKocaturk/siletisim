import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String title;
  final Color avatarBg;
  final List<Widget>? actions;

  const TopBar({
    super.key,
    required this.title,
    required this.avatarBg,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              if (actions != null) ...actions!,
              CircleAvatar(
                backgroundColor: avatarBg,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
