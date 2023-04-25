import 'package:flutter/material.dart';
import 'package:flutter_smarthome/pages/settings_page.dart';
import 'package:flutter_smarthome/pages/smart_light_control_page.dart';
import '../components/smart_device_box.dart';
import '../components/room_box.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _activeDeviceType = 'Smart Light';
  void _setActiveDeviceType(String deviceType) {
    setState(() {
      _activeDeviceType = deviceType;
    });
    print(_activeDeviceType);
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
    // [ smartDeviceName, iconPath , powerStatus ]
    ["Smart Light 1", Icons.light, true],
    ["Smart Light 2", Icons.light, false],
    ["Smart Light 3", Icons.light_mode, false],
    ["Smart Light 4", Icons.light_sharp, false],
    ["Door Lock 1", Icons.lock, false],
    ["Smart Fan 1", Icons.air, false],
  ];

  // power button switched
  void powerSwitchChanged(bool value, int index) {
    setState(() {
      _smartDevices[index][2] = value;
    });
  }

  void _navigateToSmartLight(
          String deviceName, bool isTurnedOn, Function(bool)? onChanged) =>
      {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SmartLightPage(
                  deviceName: deviceName,
                  isTurnedOn: isTurnedOn,
                  onChanged: onChanged,
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
              itemCount: _smartDevices
                  .where((device) => device[0].startsWith(_activeDeviceType))
                  .length,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1.2,
              ),
              itemBuilder: (context, index) {
                final List<dynamic> device = _smartDevices
                    .where((device) => device[0].startsWith(_activeDeviceType))
                    .elementAt(index);
                return GestureDetector(
                  onTap: () => _navigateToSmartLight(
                    device[0],
                    device[2],
                    (value) => setState(() {
                      device[2] = value;
                    }),
                  ),
                  child: SmartDeviceBox(
                    smartDeviceName: device[0],
                    icon: device[1],
                    powerOn: device[2],
                    onChanged: (value) => setState(() {
                      device[2] = value;
                    }),
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
