import 'package:flutter/material.dart';
import 'package:flutter_smarthome/services/adafruit_data_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await dotenv.load();
  final String adafruitUsername = dotenv.env['ADAFRUIT_USERNAME']!;
  final String adafruitActiveKey = dotenv.env['ADAFRUIT_ACTIVE_KEY']!;
  var box = await Hive.openBox('my_smart_devices');
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) =>
              AdafruitDataService(adafruitUsername, adafruitActiveKey))
    ],
    child: const MyApp(),
  ));
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
        home: const HomePage());
  }
}
