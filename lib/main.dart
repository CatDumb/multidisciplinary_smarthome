import 'package:flutter/material.dart';
import './pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final String adafruitUsername = dotenv.env['ADAFRUIT_USERNAME']!;
  final String adafruitActiveKey = dotenv.env['ADAFRUIT_ACTIVE_KEY']!;
  final String feedName = 'cambien1';

  final url = Uri.parse(
      'https://io.adafruit.com/api/v2/$adafruitUsername/feeds/$feedName/data');

  final response = await http.get(
    url,
    headers: {
      'X-AIO-Key': adafruitActiveKey,
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data);
    // Do something with the data here
  } else {
    print('Failed to read feed data: ${response.statusCode}');
  }

  print(adafruitUsername);
  print(adafruitActiveKey);
  print("Douma load duoc roi!");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.grey,
            textTheme: GoogleFonts.openSansTextTheme()),
        debugShowCheckedModeBanner: false,
        home: HomePage());
  }
}
