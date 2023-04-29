import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/services/adafruit_data_service.dart';

class FanControlPage extends StatefulWidget {
  AdafruitDataService adafruitDataService;
  String deviceName;
  String feedName;
  String currentValue;
  bool isTurnedOn;
  FanControlPage({
    Key? key,
    required this.adafruitDataService,
    required this.deviceName,
    required this.feedName,
    required this.currentValue,
    required this.isTurnedOn,
  }) : super(key: key);

  @override
  State<FanControlPage> createState() => _FanControlPageState();
}

class _FanControlPageState extends State<FanControlPage> {
  late int _fanPower = int.parse(widget.currentValue);

  @override
  void initState() {
    print(_fanPower);
    super.initState();
  }

  void updateFeed() {
    widget.adafruitDataService
        .sendData(feed: widget.feedName, dataValue: _fanPower.toString());
  }

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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        widget.deviceName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    (Icons.air),
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width / 5,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Slider(
                activeColor: Colors.black,
                value: _fanPower.toDouble(),
                divisions: 5,
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
