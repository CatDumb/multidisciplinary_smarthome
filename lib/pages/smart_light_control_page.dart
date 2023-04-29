import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/services/adafruit_data_service.dart';

typedef void DeviceDataCallback(
    String currentValue, String previousValue, bool isTurnedOn);

class SmartLightPage extends StatefulWidget {
  AdafruitDataService adafruitDataService;
  String deviceName;
  IconData deviceIcon;
  bool isTurnedOn;
  String feedName;
  String currentValue;
  String previousValue;
  DeviceDataCallback deviceDataCallback;
  SmartLightPage({
    Key? key,
    required this.adafruitDataService,
    required this.deviceName,
    required this.deviceIcon,
    required this.feedName,
    required this.currentValue,
    required this.previousValue,
    required this.deviceDataCallback,
    required this.isTurnedOn,
  }) : super(key: key);

  @override
  State<SmartLightPage> createState() => _SmartLightPageState();
}

class _SmartLightPageState extends State<SmartLightPage> {
  int redValue = 255;
  int greenValue = 255;
  int blueValue = 255;

  @override
  void initState() {
    super.initState();
    _getRGBValues();
  }

  void _getRGBValues() {
    if (widget.isTurnedOn) {
      setState(() {
        redValue = int.parse(widget.currentValue.substring(0, 2), radix: 16);
        greenValue = int.parse(widget.currentValue.substring(2, 4), radix: 16);
        blueValue = int.parse(widget.currentValue.substring(4, 6), radix: 16);
      });
    } else {
      setState(() {
        redValue = int.parse(widget.previousValue.substring(0, 2), radix: 16);
        greenValue = int.parse(widget.previousValue.substring(2, 4), radix: 16);
        blueValue = int.parse(widget.previousValue.substring(4, 6), radix: 16);
      });
    }
  }

  void updateFeed() {
    final hexValue =
        '${redValue.toRadixString(16).padLeft(2, '0')}${greenValue.toRadixString(16).padLeft(2, '0')}${blueValue.toRadixString(16).padLeft(2, '0')}';
    widget.adafruitDataService
        .sendData(feed: widget.feedName, dataValue: hexValue);

    // adafruitDataService.sendData(feed: 'rgb-value', value: hexValue);
  }

  void turnOff() {
    widget.adafruitDataService
        .sendData(feed: widget.feedName, dataValue: "000000");
  }

  void powerSwitchChanged(bool value) {
    setState(() {
      widget.isTurnedOn = !widget.isTurnedOn;
      _getRGBValues();
    });
    bool isTurnedOn = widget.isTurnedOn;
    widget.deviceDataCallback(
        widget.currentValue, widget.previousValue, isTurnedOn);
  }

  Color get _currentColor => Color.fromRGBO(redValue, greenValue, blueValue, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    HapticFeedback.mediumImpact();
                    powerSwitchChanged(widget.isTurnedOn);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    height: MediaQuery.of(context).size.width / 1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isTurnedOn
                          ? RadialGradient(
                              colors: [
                                _currentColor.withOpacity(1.0),
                                _currentColor.withOpacity(0.0),
                              ],
                              focalRadius: 2.0,
                              stops: const [0.0, 1.0],
                              center: Alignment.bottomCenter,
                              radius: 0.85,
                            )
                          : RadialGradient(
                              colors: [
                                _currentColor.withOpacity(0.0),
                                _currentColor.withOpacity(0.0),
                              ],
                              focalRadius: 2.0,
                              stops: const [0.0, 1.0],
                              center: Alignment.bottomCenter,
                              radius: 0.8,
                            ),
                    ),
                    child: Icon(
                      widget.deviceIcon,
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
                      updateFeed(); // send data to Adafruit server when user is done dragging
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
                      updateFeed(); // send data to Adafruit server when user is done dragging
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
                      updateFeed(); // send data to Adafruit server when user is done dragging
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
