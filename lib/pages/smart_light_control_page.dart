import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_smarthome/services/adafruit_data_service.dart';

class SmartLightPage extends StatefulWidget {
  AdafruitDataService adafruitDataService;
  String deviceName;
  IconData deviceIcon;
  bool isTurnedOn;
  String feedName;
  String currentColor;
  Function(bool) onChanged;
  SmartLightPage(
      {Key? key,
      required this.adafruitDataService,
      required this.deviceName,
      required this.deviceIcon,
      required this.feedName,
      required this.currentColor,
      required this.isTurnedOn,
      required this.onChanged})
      : super(key: key);

  @override
  State<SmartLightPage> createState() => _SmartLightPageState();
}

class _SmartLightPageState extends State<SmartLightPage> {
  // initialize Hive box
  final _myBox = Hive.box('my_smart_devices');
  bool _isOn = false;
  int redValue = 255;
  int greenValue = 255;
  int blueValue = 255;

  @override
  void initState() {
    super.initState();
    _isOn = widget.isTurnedOn;
    _getRGBValues();
  }

  void _getRGBValues() {
    setState(() {
      redValue = int.parse(widget.currentColor.substring(0, 2), radix: 16);
      greenValue = int.parse(widget.currentColor.substring(2, 4), radix: 16);
      blueValue = int.parse(widget.currentColor.substring(4, 6), radix: 16);
    });
  }

  void updateFeed() {
    final hexValue =
        '${redValue.toRadixString(16).padLeft(2, '0')}${greenValue.toRadixString(16).padLeft(2, '0')}${blueValue.toRadixString(16).padLeft(2, '0')}';
    if (_isOn) {
      widget.adafruitDataService
          .sendData(feed: widget.feedName, dataValue: hexValue);
    }

    _myBox.put(widget.feedName, hexValue);
    // adafruitDataService.sendData(feed: 'rgb-value', value: hexValue);
  }

  void turnOff() {
    widget.adafruitDataService
        .sendData(feed: widget.feedName, dataValue: "000000");
  }

  void powerSwitchChanged(bool value) {
    if (value == true) {
      turnOff();
    } else {
      widget.adafruitDataService.sendData(
          feed: widget.feedName,
          dataValue: _myBox.get(widget.feedName, defaultValue: "ffffff"));
    }
    setState(() {
      value = !value;
      _isOn = value;
      // _getRGBValues();
    });
    widget.onChanged(value);
  }

  Color get _currentColor => Color.fromRGBO(redValue, greenValue, blueValue, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          widget.deviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    powerSwitchChanged(_isOn);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.05,
                    height: MediaQuery.of(context).size.width / 1,
                    decoration: BoxDecoration(
                      border: _currentColor.toString() == "Color(0xffffffff)"
                          ? Border.all(color: Colors.white)
                          : Border.all(color: Colors.white),
                      shape: BoxShape.circle,
                      gradient: _isOn
                          ? RadialGradient(
                              colors: [
                                _currentColor.withOpacity(1.0),
                                _currentColor.withOpacity(0.2),
                              ],
                              focalRadius: 1.0,
                              stops: const [0.0, 1.0],
                              center: Alignment.bottomCenter,
                              radius: 1,
                            )
                          : const RadialGradient(
                              colors: [Colors.transparent, Colors.transparent],
                              focalRadius: 2.0,
                              stops: [0.0, 1.0],
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
