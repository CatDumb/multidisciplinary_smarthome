import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';

class SmartLightPage extends StatefulWidget {
  String deviceName;
  bool isTurnedOn;
  SmartLightPage({Key? key, required this.deviceName, required this.isTurnedOn})
      : super(key: key);

  @override
  State<SmartLightPage> createState() => _SmartLightPageState();
}

class _SmartLightPageState extends State<SmartLightPage> {
  void powerSwitchChanged(bool value) {
    setState(() {
      value = !value;
    });
  }

  double redValue = 0;
  double greenValue = 255;
  double blueValue = 0;

  Color get currentColor => Color.fromRGBO(
      redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: currentColor,
                size: MediaQuery.of(context).size.width / 3,
              ),
              CupertinoSwitch(
                value: widget.isTurnedOn,
                onChanged: (value) => powerSwitchChanged(value),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Red'),
                    Slider(
                      value: redValue,
                      min: 0,
                      max: 255,
                      onChanged: (value) {
                        setState(() {
                          redValue = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Green'),
                    Slider(
                      value: greenValue,
                      min: 0,
                      max: 255,
                      onChanged: (value) {
                        setState(() {
                          greenValue = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Blue'),
                    Slider(
                      value: blueValue,
                      min: 0,
                      max: 255,
                      onChanged: (value) {
                        setState(() {
                          blueValue = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
