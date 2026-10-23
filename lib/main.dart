import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M7uh2link', // ← الاسم الجديد
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoKufiArabic',
        scaffoldBackgroundColor: Colors.white,
      ),
      locale: const Locale('ckb'),
      supportedLocales: const [Locale('ckb'), Locale('en')],
      home: const HomeScreen(),
    );
  }
}
