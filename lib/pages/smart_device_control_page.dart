import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/services/adafruit_data_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SmartDevicePage extends StatefulWidget {
  String deviceName;
  String feedName;
  String currentValue;
  String previousValue;
  bool isTurnedOn;
  Function(bool value)? onChanged;
  SmartDevicePage({
    Key? key,
    required this.deviceName,
    required this.feedName,
    required this.currentValue,
    required this.previousValue,
    required this.isTurnedOn,
    this.onChanged,
  }) : super(key: key);

  @override
  State<SmartDevicePage> createState() => _SmartDevicePageState();
}

class _SmartDevicePageState extends State<SmartDevicePage> {
  int redValue = 255;
  int greenValue = 255;
  int blueValue = 255;
  final String adafruitUsername = dotenv.env['ADAFRUIT_USERNAME']!;
  final String adafruitActiveKey = dotenv.env['ADAFRUIT_ACTIVE_KEY']!;
  late AdafruitDataService adafruitDataService =
      AdafruitDataService(adafruitUsername, adafruitActiveKey);

  String _currentValue = "";
  @override
  void initState() {
    super.initState();
    _fetchCurrentValue();
    _fetchTwoLastValues();
  }

  Future<void> _fetchCurrentValue() async {
    try {
      final value = await adafruitDataService.fetchData(feed: "led1");
      setState(() {
        _currentValue = value;
        redValue = int.parse(_currentValue.substring(0, 2), radix: 16);
        greenValue = int.parse(_currentValue.substring(2, 4), radix: 16);
        blueValue = int.parse(_currentValue.substring(4, 6), radix: 16);
      });
    } catch (e) {
      // handle error
    }
  }

  Future<void> _fetchTwoLastValues() async {
    try {
      final lastTwoValues =
          await adafruitDataService.fetchLastTwoData(feed: "led1");
      print(lastTwoValues);
      // INDEX 0 : LATEST; INDEX 1: PREVIOUS
    } catch (e) {
      // handle error
    }
  }

  void updateFeed() {
    final hexValue =
        '${redValue.toRadixString(16).padLeft(2, '0')}${greenValue.toRadixString(16).padLeft(2, '0')}${blueValue.toRadixString(16).padLeft(2, '0')}';
    adafruitDataService.sendData(feed: "led1", dataValue: hexValue);

    // adafruitDataService.sendData(feed: 'rgb-value', value: hexValue);
  }

  void turnOff() {
    adafruitDataService.sendData(feed: "led1", dataValue: "000000");
  }

  void powerSwitchChanged(bool value) {
    setState(() {
      widget.isTurnedOn = !widget.isTurnedOn;
    });

    if (widget.onChanged != null) {
      widget.onChanged!(widget.isTurnedOn);
    }
  }

  late final String _currentColor = "0xFF$_currentValue";

  Color get currentColor => Color.fromRGBO(redValue, greenValue, blueValue, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          "Customizing device",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Color(int.parse(_currentColor)),
              height: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.deviceName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    powerSwitchChanged(widget.isTurnedOn);
                    if (!widget.isTurnedOn) {
                      turnOff();
                    } else {
                      updateFeed();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    height: MediaQuery.of(context).size.width / 1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isTurnedOn
                          ? RadialGradient(
                              colors: [
                                currentColor.withOpacity(1.0),
                                currentColor.withOpacity(0.0),
                              ],
                              focalRadius: 2.0,
                              stops: const [0.0, 1.0],
                              center: Alignment.bottomCenter,
                              radius: 0.85,
                            )
                          : RadialGradient(
                              colors: [
                                currentColor.withOpacity(0.0),
                                currentColor.withOpacity(0.0),
                              ],
                              focalRadius: 2.0,
                              stops: const [0.0, 1.0],
                              center: Alignment.bottomCenter,
                              radius: 0.8,
                            ),
                    ),
                    child: Icon(
                      Icons.light,
                      color: Colors.black,
                      size: MediaQuery.of(context).size.width / 5,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Slider(
                    activeColor: Colors.red,
                    value: redValue.toDouble(),
                    min: 0,
                    max: 255,
                    onChanged: (value) {
                      setState(() {
                        redValue = value.toInt();
                      });
                    },
                    onChangeEnd: (value) {
                      // updateFeed(); // send data to Adafruit server when user is done dragging
                    },
                  ),
                  Slider(
                    activeColor: Colors.green,
                    value: greenValue.toDouble(),
                    min: 0,
                    max: 255,
                    onChanged: (value) {
                      setState(() {
                        greenValue = value.toInt();
                      });
                    },
                    onChangeEnd: (value) {
                      // updateFeed(); // send data to Adafruit server when user is done dragging
                    },
                  ),
                  Slider(
                    activeColor: Colors.blue,
                    value: blueValue.toDouble(),
                    min: 0,
                    max: 255,
                    onChanged: (value) {
                      setState(() {
                        blueValue = value.toInt();
                      });
                    },
                    onChangeEnd: (value) {
                      // updateFeed(); // send data to Adafruit server when user is done dragging
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
