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

typedef void DeviceDataCallback(
    String currentValue, String previousValue, bool isTurnedOn);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String adafruitUsername = dotenv.env['ADAFRUIT_USERNAME']!;
  final String adafruitActiveKey = dotenv.env['ADAFRUIT_ACTIVE_KEY']!;
  late AdafruitDataService adafruitDataService =
      AdafruitDataService(adafruitUsername, adafruitActiveKey);
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

  void _updateSmartDevice(
      String feedName, String currentValue, String previousValue) {
    final int deviceIndex =
        _newSmartDevices.indexWhere((device) => device[5] == feedName);
    if (deviceIndex != -1) {
      _newSmartDevices[deviceIndex][3] =
          currentValue != "000000" && currentValue != "0";
    }
  }

  Future<void> _fetchInitValues() async {
    try {
      final led1Values =
          await adafruitDataService.fetchLastTwoData(feed: "led1");
      final led2Values =
          await adafruitDataService.fetchLastTwoData(feed: "led2");
      final led3Values =
          await adafruitDataService.fetchLastTwoData(feed: "led3");
      final led4Values =
          await adafruitDataService.fetchLastTwoData(feed: "led4");
      final doorLockValues = await adafruitDataService.fetchData(feed: "door");
      final fanValue = await adafruitDataService.fetchData(feed: "fan");
      print(fanValue);

      setState(() {
        // led 1
        _newSmartDevices[0][3] = led1Values[0];
        _newSmartDevices[0][4] = led1Values[1];
        // led2
        _newSmartDevices[1][3] = led2Values[0];
        _newSmartDevices[1][4] = led2Values[1];
        // led 1
        _newSmartDevices[2][3] = led3Values[0];
        _newSmartDevices[2][4] = led3Values[1];
        // led2
        _newSmartDevices[3][3] = led4Values[0];
        _newSmartDevices[3][4] = led4Values[1];
        // door
        _newSmartDevices[4][3] = doorLockValues;
        // fan
        _newSmartDevices[5][3] = fanValue;
      });
      for (int i = 0; i < _newSmartDevices.length; i++) {
        // print(_newSmartDevices[i][3]);
        if (_newSmartDevices[i][3].toString() == "0" ||
            _newSmartDevices[i][3].toString() == "000000") {
          setState(() {
            _newSmartDevices[i][2] = false;
          });
        } else {
          setState(() {
            _newSmartDevices[i][2] = true;
          });
        }
      }
    } catch (e) {
      // handle error
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

  final List _newSmartDevices = [
    // [ smartDeviceName, iconPath, powerStatus, currentValue, previousValue, feedName ]
    ["Smart Light 1", Icons.lightbulb_outline, false, "", "", 'led1'],
    ["Smart Light 2", Icons.lightbulb_outline, false, "", "", 'led2'],
    ["Smart Light 3", Icons.lightbulb_outline, false, "", "", 'led3'],
    ["Smart Light 4", Icons.lightbulb_outline, false, "", "", 'led4'],
    ["Door Lock 1", Icons.lock, "", "", false, 'door'],
    ["Smart Fan 1", Icons.air, "", "", false, 'fan'],
  ];

  // power button switched
  void powerSwitchChanged(bool value, int index) {
    setState(() {
      _newSmartDevices[index][2] = value;
    });
  }

  void _navigateToSmartFan(
      AdafruitDataService adafruitDataService,
      String deviceName,
      String feedName,
      String currentValue,
      bool isTurnedOn) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FanControlPage(
              adafruitDataService: adafruitDataService,
              deviceName: deviceName,
              feedName: feedName,
              currentValue: currentValue,
              isTurnedOn: isTurnedOn,
            )));
  }

  void _navigateToSmartLight(
          String deviceName,
          IconData deviceIcon,
          String feedName,
          String currentValue,
          String previousValue,
          bool isTurnedOn,
          DeviceDataCallback deviceDataCallback) =>
      {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SmartLightPage(
                  adafruitDataService: adafruitDataService,
                  deviceName: deviceName,
                  deviceIcon: deviceIcon,
                  feedName: feedName,
                  currentValue: currentValue,
                  previousValue: previousValue,
                  isTurnedOn: isTurnedOn,
                  deviceDataCallback: deviceDataCallback,
                )))
      };

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
                    Text("Your smarthome is ready"),
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
                      roomIcon: Icons.lightbulb_outline_sharp,
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
            child: GridView.builder(
              itemCount: _newSmartDevices
                  .where((device) => device[0].startsWith(_activeDeviceType))
                  .length,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1.2,
              ),
              itemBuilder: (context, index) {
                final List<dynamic> device = _newSmartDevices
                    .where((device) => device[0].startsWith(_activeDeviceType))
                    .elementAt(index);
                return GestureDetector(
                  onTap: () {
                    if (device[0].startsWith("Smart Light")) {
                      _navigateToSmartLight(
                        device[0],
                        device[1],
                        device[5],
                        device[3],
                        device[4],
                        device[2],
                        (newValue, newPreviousValue, newValueIsOn) {
                          setState(() {
                            device[2] = newValueIsOn;
                            device[3] = newValue;
                            device[4] = newPreviousValue;
                          });
                          adafruitDataService.sendData(
                            feed: device[5],
                            dataValue:
                                (newValueIsOn == false) ? "000000" : newValue,
                          );
                        },
                      );
                    } else if (device[0].startsWith("Door Lock")) {
                      // String dataToSend = device[2] ? '1' : '0';
                      setState(() {
                        device[2] = !device[2];
                      });
                      adafruitDataService.sendData(
                        feed: device[5],
                        dataValue: device[2] ? '1' : '0',
                      );
                    } else {
                      _navigateToSmartFan(
                        adafruitDataService,
                        device[0],
                        device[5],
                        device[3],
                        device[2],
                      );
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
                        if (value == true) {
                          // If turning on the light
                          if (device[3] == "000000") {
                            // If current value is RGB color
                            dataToSend = device[
                                4]; // Use previous value to turn on the light
                          } else {
                            dataToSend = device[
                                3]; // Use current value to turn on the light
                          }
                        } else {
                          // If turning off the light
                          dataToSend =
                              "000000"; // Send "000000" to turn off the light
                        }
                      } else if (device[0].startsWith("Door Lock")) {
                        if (value == true) {
                          dataToSend = "1";
                        } else {
                          dataToSend = "0";
                        }
                      } else {
                        if (value == true) {
                          dataToSend = "40";
                        } else {
                          dataToSend = "0";
                        }
                      }
                      adafruitDataService.sendData(
                          feed: device[5], dataValue: dataToSend);
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
