import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Generate Icon', () async {
    // حجم الصورة
    const size = Size(1024, 1024);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 1. رسم الخلفية البيضاء
    final paintBg = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBg);

    // 2. رسم الدائرة السوداء
    final paintCircle = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 380, paintCircle);

    // 3. رسم السهم الأزرق (الجسم)
    final paintArrow = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 70
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(680, 380);
    path.lineTo(450, 380);
    path.quadraticBezierTo(320, 380, 320, 512);
    path.quadraticBezierTo(320, 644, 450, 644);
    path.lineTo(550, 644);
    canvas.drawPath(path, paintArrow);

    // 4. رسم رأس السهم الأزرق (المثلث)
    final paintHead = Paint()..color = const Color(0xFF2196F3);
    final headPath = Path();
    headPath.moveTo(500, 290);
    headPath.lineTo(320, 380);
    headPath.lineTo(500, 470);
    headPath.close();
    canvas.drawPath(headPath, paintHead);

    // 5. حفظ الصورة في مجلد assets/icon
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final file = File('assets/icon/app_icon.png');
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(buffer);
    
    print('✅ تم رسم الأيقونة وحفظها بنجاح!');
  });
}
