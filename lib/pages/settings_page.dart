import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text("Smart Home"),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: const SafeArea(
          child: Center(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text("Developed by Đồ ăn 222 team.")),
      )),
    );
  }
}
