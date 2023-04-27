import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/services/adafruit_data_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FanControlPage extends StatefulWidget {
  AdafruitDataService adafruitDataService;
  String deviceName;
  String feedName;
  String currentValue;
  String previousValue;
  bool isTurnedOn;
  Function(bool value)? onChanged;
  FanControlPage({
    Key? key,
    required this.adafruitDataService,
    required this.deviceName,
    required this.feedName,
    required this.currentValue,
    required this.previousValue,
    required this.isTurnedOn,
    this.onChanged,
  }) : super(key: key);

  @override
  State<FanControlPage> createState() => _FanControlPageState();
}

class _FanControlPageState extends State<FanControlPage> {
  late int _fanPower = int.parse(widget.currentValue);
  @override
  void initState() {
    super.initState();
  }

  void updateFeed() {
    widget.adafruitDataService
        .sendData(feed: widget.feedName, dataValue: _fanPower.toString());
  }

  void turnOff() {
    widget.adafruitDataService.sendData(feed: widget.feedName, dataValue: "0");
  }

  void powerSwitchChanged(bool value) {
    setState(() {
      widget.isTurnedOn = !widget.isTurnedOn;
    });

    if (widget.onChanged != null) {
      widget.onChanged!(widget.isTurnedOn);
    }
  }

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
                                (Colors.grey).withOpacity(1.0),
                                Colors.grey.withOpacity(0.0),
                              ],
                              focalRadius: 2.0,
                              stops: const [0.0, 1.0],
                              center: Alignment.bottomCenter,
                              radius: 0.85,
                            )
                          : RadialGradient(
                              colors: [
                                Colors.grey.withOpacity(0.0),
                                Colors.grey.withOpacity(0.0),
                              ],
                              focalRadius: 2.0,
                              stops: const [0.0, 1.0],
                              center: Alignment.bottomCenter,
                              radius: 0.8,
                            ),
                    ),
                    child: Icon(
                      (Icons.air),
                      color: Colors.black,
                      size: MediaQuery.of(context).size.width / 5,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Slider(
                activeColor: Colors.black,
                value: _fanPower.toDouble(),
                min: 0,
                max: 100,
                onChanged: (value) {
                  setState(() {
                    _fanPower = value.toInt();
                  });
                },
                onChangeEnd: (value) {
                  updateFeed(); // send data to Adafruit server when user is done dragging
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
