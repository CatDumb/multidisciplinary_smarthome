import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/adafruit_data_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // initialize Adafruit data service
  final String adafruitUsername = dotenv.env['ADAFRUIT_USERNAME']!;
  final String adafruitActiveKey = dotenv.env['ADAFRUIT_ACTIVE_KEY']!;
  late AdafruitDataService adafruitDataService =
      AdafruitDataService(adafruitUsername, adafruitActiveKey);

  final _myBox = Hive.box('my_smart_devices');

  List<DataPoint> _dataPoints = [];
  List<DataPoint> _humidityPoints = [];
  late bool _isLoading;
  late String _currentTemp = _myBox.get('temp', defaultValue: "...");
  late String _currentHum = _myBox.get('hum', defaultValue: "...");

  late String _currentLock = "...";
  Timer? _timer;

  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _isLoading = true;
    _fetchThermostatAndHumidData();
    _fetchLockData();
    _isLoading = false;
    _timer = Timer.periodic(
        const Duration(seconds: 5), (_) => _fetchThermostatAndHumidData());
    _myBox.put('temp', _currentTemp);
  }

  void _fetchLockData() async {
    final lockStatus = await adafruitDataService.fetchData(feed: "door");
    if (_isMounted) {
      setState(() {
        _currentLock = lockStatus == "1" ? "true" : "false";
      });
    }
  }

  void _fetchThermostatAndHumidData() async {
    final currentTemp = await adafruitDataService.fetchData(feed: "temp");
    final currentHum = await adafruitDataService.fetchData(feed: "hum");
    if (_isMounted) {
      setState(() {
        _currentTemp = currentTemp;
        _currentHum = currentHum;
        _dataPoints
            .add(DataPoint((_dataPoints.length), double.parse(currentTemp)));
        _humidityPoints
            .add(DataPoint((_humidityPoints.length), double.parse(currentHum)));
      });
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          "Smart Home Statistics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Home temperature and humidity",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              StatsBox(
                                deviceReading: "$_currentTempºC",
                                fillColor: Colors.black,
                              ),
                              StatsBox(
                                deviceReading: "$_currentHum%",
                                fillColor: Colors.teal,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Line chart",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )
                            ],
                          ),
                        ),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.1,
                            height: MediaQuery.of(context).size.height / 2.5,
                            child: SfCartesianChart(
                              legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              primaryXAxis: NumericAxis(),
                              primaryYAxis: NumericAxis(),
                              series: <LineSeries<DataPoint, int>>[
                                LineSeries<DataPoint, int>(
                                  name: "Temperature (ºC)",
                                  color: Colors.black,
                                  dataSource: _dataPoints,
                                  xValueMapper: (DataPoint data, _) => data.x,
                                  yValueMapper: (DataPoint data, _) => data.y,
                                ),
                                LineSeries<DataPoint, int>(
                                  color: Colors.teal,
                                  dataSource:
                                      _humidityPoints, // your humidity data
                                  xValueMapper: (DataPoint data, _) => data.x,
                                  yValueMapper: (DataPoint data, _) => data.y,
                                  name: 'Humidity (%)',
                                  // other properties
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text("Developed by Đồ ăn 222 team.")),
                    ),
                  ],
                )),
    );
  }
}

class StatsBox extends StatelessWidget {
  String deviceReading;
  Color fillColor;
  StatsBox({Key? key, required this.deviceReading, required this.fillColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(width: 2),
            borderRadius: BorderRadius.circular(16),
            color: fillColor),
        width: MediaQuery.of(context).size.width / 3,
        height: MediaQuery.of(context).size.height / 6,
        child: Center(
            child: Text(
          deviceReading,
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        )),
      ),
    );
  }
}

class DataPoint {
  final int x;
  final double y;

  DataPoint(this.x, this.y);
}
