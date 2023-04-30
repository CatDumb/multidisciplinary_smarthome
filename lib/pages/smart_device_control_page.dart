import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/services/adafruit_data_service.dart';

class FanControlPage extends StatefulWidget {
  AdafruitDataService adafruitDataService;
  String deviceName;
  String feedName;
  String currentValue;
  bool isTurnedOn;
  final ValueChanged<bool> onValueChanged;
  final ValueChanged<String> onPowerChanged;

  FanControlPage(
      {Key? key,
      required this.adafruitDataService,
      required this.deviceName,
      required this.feedName,
      required this.currentValue,
      required this.isTurnedOn,
      required this.onValueChanged,
      required this.onPowerChanged})
      : super(key: key);

  @override
  State<FanControlPage> createState() => _FanControlPageState();
}

class _FanControlPageState extends State<FanControlPage> {
  late int _fanPower;

  @override
  void initState() {
    _fanPower = int.parse(widget.currentValue);
    super.initState();
  }

  void updateFeed() {
    if (_fanPower == 0) {
      setState(() {
        widget.isTurnedOn = false;
        widget.currentValue = "0";
      });
      widget.onValueChanged(false);
      widget.onPowerChanged("0");
    } else {
      setState(() {
        widget.isTurnedOn = true;
        widget.currentValue = _fanPower.toString();
      });
      widget.onValueChanged(true);
      widget.onPowerChanged(_fanPower.toString());
    }
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
