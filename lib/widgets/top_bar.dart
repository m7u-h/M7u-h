import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onHistoryTap;

  const TopBar({super.key, required this.onHistoryTap});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // الجزء الأيمن: زر الحافظة
            GestureDetector(
              onTap: onHistoryTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF151E23),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.history, color: Colors.white, size: 18),
                    SizedBox(width: 5),
                    Text(
                      'داگرتەکان',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            // الجزء الأيسر: اليوزر والأيقونات
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF151E23),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text(
                    'm7u_h@',
                    style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  const Icon(FontAwesomeIcons.snapchat, color: Color(0xFFFFFC00), size: 20),
                  const SizedBox(width: 8),
                  const Icon(FontAwesomeIcons.telegram, color: Color(0xFF0088CC), size: 20),
                  const SizedBox(width: 8),
                  const Icon(FontAwesomeIcons.tiktok, color: Colors.white, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
