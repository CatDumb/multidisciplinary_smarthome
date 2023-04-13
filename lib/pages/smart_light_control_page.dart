import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/main.dart';

class SmartLightPage extends StatefulWidget {
  String deviceName;
  bool isTurnedOn;
  Function(bool value)? onChanged;
  SmartLightPage({
    Key? key,
    required this.deviceName,
    required this.isTurnedOn,
    this.onChanged,
  }) : super(key: key);

  @override
  State<SmartLightPage> createState() => _SmartLightPageState();
}

class _SmartLightPageState extends State<SmartLightPage> {
  void powerSwitchChanged(bool value) {
    setState(() {
      widget.isTurnedOn = !widget.isTurnedOn;
    });

    if (widget.onChanged != null) {
      widget.onChanged!(widget.isTurnedOn);
    }
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    powerSwitchChanged(widget.isTurnedOn);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.width / 1.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isTurnedOn
                          ? RadialGradient(
                              colors: [
                                currentColor.withOpacity(1.0),
                                currentColor.withOpacity(0.0),
                              ],
                              focalRadius: 2.0,
                              stops: [0.0, 1.0],
                              center: Alignment.bottomCenter,
                              radius: 0.8,
                            )
                          : RadialGradient(
                              colors: [
                                currentColor.withOpacity(0.0),
                                currentColor.withOpacity(0.0),
                              ],
                              focalRadius: 2.0,
                              stops: [0.0, 1.0],
                              center: Alignment.bottomCenter,
                              radius: 0.8,
                            ),
                    ),
                    child: Hero(
                      tag: 'device-${widget.deviceName}',
                      child: Icon(
                        Icons.light,
                        color: Colors.black,
                        size: MediaQuery.of(context).size.width / 5,
                      ),
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
                    value: redValue,
                    min: 0,
                    max: 255,
                    onChanged: (value) {
                      setState(() {
                        redValue = value;
                      });
                    },
                  ),
                  Slider(
                    activeColor: Colors.green,
                    value: greenValue,
                    min: 0,
                    max: 255,
                    onChanged: (value) {
                      setState(() {
                        greenValue = value;
                      });
                    },
                  ),
                  Slider(
                    activeColor: Colors.blue,
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
            ),
          ],
        ),
      ),
    );
  }
}
