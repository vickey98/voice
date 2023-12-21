import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_app/app/data/api/service/api_service.dart';
import 'package:voice_app/app/modules/speech_screen/views/speech_screen_view.dart';

void main() async {
  await initService();
  runApp(const MyApp());
}

initService() async {
  await Get.putAsync(() => ApiService().init());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primarySwatch: Colors.deepPurple),
      home: const SpeechScreen(),
    );
  }
}
