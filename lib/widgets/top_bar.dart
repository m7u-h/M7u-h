import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onHistoryTap;

  const TopBar({super.key, required this.onHistoryTap});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // اسم المستخدم على اليمين (بسبب الـ RTL)
          const Text(
            'm7u_h@',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          Row(
            children: [
              // أيقونة تلكرام
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.telegram, color: Color(0xFF0088CC), size: 24),
                onPressed: () {},
              ),
              // أيقونة تيك توك
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.tiktok, color: Colors.black, size: 24),
                onPressed: () {},
              ),
              // أيقونة سناب شات
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.snapchat, color: Color(0xFFFFFC00), size: 24),
                onPressed: () {},
              ),
              // زر الحافظة على اليسار
              IconButton(
                icon: const Icon(Icons.history, color: Colors.black, size: 28),
                onPressed: onHistoryTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
