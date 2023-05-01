// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_smarthome/pages/settings_page.dart';
import 'package:flutter_smarthome/pages/smart_light_control_page.dart';
import '../components/smart_device_box.dart';
import 'smart_device_control_page.dart';
import '../components/room_box.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/adafruit_data_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // initialize Adafruit data service
  final String adafruitUsername = dotenv.env['ADAFRUIT_USERNAME']!;
  final String adafruitActiveKey = dotenv.env['ADAFRUIT_ACTIVE_KEY']!;
  late AdafruitDataService adafruitDataService =
      AdafruitDataService(adafruitUsername, adafruitActiveKey);

  // initialize Hive key-value database
  final _myBox = Hive.box('my_smart_devices');

  late bool _isLoading;
  String _activeDeviceType = 'Smart Light';
  void _setActiveDeviceType(String deviceType) {
    setState(() {
      _activeDeviceType = deviceType;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchInitValues();
  }

  Future<void> _fetchInitValues() async {
    setState(() {
      _isLoading = true; // Set isLoading to true to show the loading indicator
    });
    try {
      // this fetch purely tells whether the light is on
      final led1Value = await adafruitDataService.fetchData(feed: "led1");
      final led2Value = await adafruitDataService.fetchData(feed: "led2");
      final led3Value = await adafruitDataService.fetchData(feed: "led3");
      final led4Value = await adafruitDataService.fetchData(feed: "led4");

      if (led1Value != "000000" && led1Value != "ffffff") {
        _myBox.put('led1', led1Value);
      }
      if (led2Value != "000000" && led2Value != "ffffff") {
        _myBox.put('led2', led2Value);
      }
      if (led3Value != "000000" && led3Value != "ffffff") {
        _myBox.put('led3', led3Value);
      }
      if (led4Value != "000000" && led4Value != "ffffff") {
        _myBox.put('led4', led4Value);
      }

      // door value
      final doorLockValues = await adafruitDataService.fetchData(feed: "door");
      // fan value
      final fanValue = await adafruitDataService.fetchData(feed: "fan");

      setState(() {
        // led 1
        _smartDevices[0][3] = led1Value;
        // led2
        _smartDevices[1][3] = led2Value;
        // led 3
        _smartDevices[2][3] = led3Value;
        // led 4
        _smartDevices[3][3] = led4Value;
        // door
        _smartDevices[4][3] = doorLockValues;
        // fan
        _smartDevices[5][3] = fanValue;
        _isLoading = false; // done loading
      });

      // update powerStatus
      for (int i = 0; i < _smartDevices.length; i++) {
        // print(_newSmartDevices[i][3]);
        if (_smartDevices[i][3].toString() == "0" ||
            _smartDevices[i][3].toString() == "000000") {
          setState(() {
            _smartDevices[i][2] = false;
          });
        } else {
          setState(() {
            _smartDevices[i][2] = true;
          });
        }
      }
    } catch (e) {
      // handle error
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Oops!"),
            content: Text(e.toString()),
            actions: [
              ElevatedButton(
                onPressed: () {},
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<bool> isActiveList = [true, false, false, false];
  void updateIsActive(int index) {
    setState(() {
      if (isActiveList[index] != true) {
        isActiveList[index] = true;
      }
      for (int i = 0; i < isActiveList.length; i++) {
        if (i != index) {
          isActiveList[i] = false;
        }
      }
    });
  }

  final List _smartDevices = [
    // [ smartDeviceName, iconPath, powerStatus, currentValue, previousValue, feedName ]
    ["Smart Light 1", Icons.lightbulb_outline, false, "", 'led1'],
    ["Smart Light 2", Icons.lightbulb_outline, false, "", 'led2'],
    ["Smart Light 3", Icons.lightbulb_outline, false, "", 'led3'],
    ["Smart Light 4", Icons.lightbulb_outline, false, "", 'led4'],
    ["Door Lock 1", Icons.lock, false, "", 'door'],
    ["Smart Fan 1", Icons.air, false, "", 'fan'],
  ];

  // power button switched
  void powerSwitchChanged(bool value, int index) {
    setState(() {
      _smartDevices[index][2] = value;
    });
  }

  void _handleFanValueChanged(bool newValue) {
    setState(() {
      _smartDevices[5][2] = newValue;
    });
  }

  void _updateFanValue(String newValue) {
    setState(() {
      _smartDevices[5][3] = newValue;
    });
  }

  void _navigateToSmartFan(
      AdafruitDataService adafruitDataService,
      String deviceName,
      String feedName,
      String currentValue,
      bool isTurnedOn,
      ValueChanged<bool> onValueChanged,
      ValueChanged<String> onPowerChanged) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FanControlPage(
              adafruitDataService: adafruitDataService,
              deviceName: deviceName,
              feedName: feedName,
              currentValue: currentValue,
              isTurnedOn: isTurnedOn,
              onValueChanged: onValueChanged,
              onPowerChanged: onPowerChanged,
            )));
  }

  void _navigateToSettings() => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SettingPage()))
      };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: const Icon(
          Icons.menu_outlined,
          size: 30,
        ),
        actions: [
          GestureDetector(
              onTap: _navigateToSettings,
              child: const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(Icons.person_outline, size: 30),
              ))
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // hello text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: const [
                    Text(
                      "Welcome back!",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Text("Your smart home is ready"),
                  ],
                ),
              ],
            ),
          ),
          // active rooms
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10),
            child: SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      updateIsActive(0);
                      _setActiveDeviceType("Smart Light");
                    },
                    child: DeviceTypeBox(
                      roomIcon: Icons.lightbulb_outline,
                      roomName: "Smart Lights",
                      isActive: isActiveList[0],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      updateIsActive(1);
                      _setActiveDeviceType("Door Lock");
                    },
                    child: DeviceTypeBox(
                      roomIcon: Icons.lock,
                      roomName: "Door Locks",
                      isActive: isActiveList[1],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      updateIsActive(2);
                      _setActiveDeviceType("Smart Fan");
                    },
                    child: DeviceTypeBox(
                      roomIcon: Icons.air,
                      roomName: "Fans",
                      isActive: isActiveList[2],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Devices",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Icon(Icons.more_horiz)
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : GridView.builder(
                    itemCount: _smartDevices
                        .where(
                            (device) => device[0].startsWith(_activeDeviceType))
                        .length,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 1.2,
                    ),
                    itemBuilder: (context, index) {
                      final List<dynamic> device = _smartDevices
                          .where((device) =>
                              device[0].startsWith(_activeDeviceType))
                          .elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          if (device[0].startsWith("Smart Light")) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SmartLightPage(
                                      adafruitDataService: adafruitDataService,
                                      deviceName: device[0],
                                      deviceIcon: device[1],
                                      feedName: device[4],
                                      currentColor: _myBox.get(device[4],
                                          defaultValue: 'ffffff'),
                                      isTurnedOn: device[2],
                                      onChanged: (value) => {
                                        setState(() {
                                          device[2] = value;
                                        })
                                      },
                                    )));
                            print("Stop being dumb ${device[2]}");
                          } else if (device[0].startsWith("Door Lock")) {
                            // String dataToSend = device[2] ? '1' : '0';
                            setState(() {
                              device[2] = !device[2];
                            });
                            adafruitDataService.sendData(
                              feed: device[4],
                              dataValue: device[2] ? '1' : '0',
                            );
                          } else {
                            _navigateToSmartFan(
                                adafruitDataService,
                                device[0],
                                device[4],
                                device[3],
                                device[2],
                                _handleFanValueChanged,
                                _updateFanValue);
                          }
                        },
                        child: SmartDeviceBox(
                          smartDeviceName: device[0],
                          icon: device[1],
                          powerOn: device[2],
                          onChanged: (value) {
                            setState(() {
                              device[2] = value;
                            });
                            String dataToSend;
                            if (device[0].startsWith("Smart Light")) {
                              final lightColor =
                                  _myBox.get(device[4], defaultValue: "ffffff");
                              if (value == true) {
                                // If turning on the light
                                dataToSend = lightColor;
                              } else {
                                // If turning off the light
                                dataToSend = "000000"; // turn light off
                              }
                            } else if (device[0].startsWith("Door Lock")) {
                              if (value == true) {
                                dataToSend = "1";
                              } else {
                                dataToSend = "0";
                              }
                            } else {
                              // fan control here

                              if (value == true) {
                                setState(() {
                                  device[3] = "40";
                                });
                                dataToSend = "40";
                              } else {
                                setState(() {
                                  device[3] = "0";
                                });
                                dataToSend = "0";
                              }
                            }
                            adafruitDataService.sendData(
                                feed: device[4], dataValue: dataToSend);
                          },
                        ),
                      );
                    },
                  ),
          )

          // devices
        ]),
      ),
    );
  }
}
