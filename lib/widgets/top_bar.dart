import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onHistoryTap;

  const TopBar({super.key, required this.onHistoryTap});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'm7u_h@',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.snapchat, color: Color(0xFFFFFC00)),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.music_note, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.telegram, color: Color(0xFF0088CC)),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.history, color: Colors.black),
                onPressed: onHistoryTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
