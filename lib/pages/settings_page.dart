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
  late bool _isLoading;
  late String _currentTemp = _myBox.get('temp', defaultValue: "...");
  late String _currentLock = "...";
  Timer? _timer;

  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _isLoading = true;
    _fetchThermostatData();
    _fetchLockData();
    _isLoading = false;
    _timer = Timer.periodic(
        const Duration(seconds: 5), (_) => _fetchThermostatData());
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

  void _fetchThermostatData() async {
    final currentTemp = await adafruitDataService.fetchData(feed: "temp");
    if (_isMounted) {
      setState(() {
        _currentTemp = currentTemp;
        _dataPoints
            .add(DataPoint((_dataPoints.length), double.parse(currentTemp)));
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
        title: const Text("Smart Home Statistics"),
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
                                "Home temp and door",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Icon(Icons.more_horiz)
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
                                deviceReading: _currentLock == "true"
                                    ? "Locked"
                                    : "Unlocked",
                                fillColor: _currentLock == "true"
                                    ? Colors.red
                                    : Colors.green,
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
                                "Temperature chart",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )
                            ],
                          ),
                        ),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.1,
                            height: MediaQuery.of(context).size.height / 2,
                            child: SfCartesianChart(
                              legend: Legend(
                                  title: LegendTitle(text: "Temp (ºC)"),
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              primaryXAxis: NumericAxis(),
                              primaryYAxis: NumericAxis(),
                              series: <LineSeries<DataPoint, int>>[
                                LineSeries<DataPoint, int>(
                                  color: Colors.black,
                                  dataSource: _dataPoints,
                                  xValueMapper: (DataPoint data, _) => data.x,
                                  yValueMapper: (DataPoint data, _) => data.y,
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
