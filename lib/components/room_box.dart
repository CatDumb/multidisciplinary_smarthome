import 'package:flutter/material.dart';

class DeviceTypeBox extends StatefulWidget {
  final IconData roomIcon;
  final String roomName;
  bool isActive;

  DeviceTypeBox(
      {Key? key,
      required this.roomIcon,
      required this.roomName,
      required this.isActive})
      : super(key: key);

  @override
  _DeviceTypeBoxState createState() => _DeviceTypeBoxState();
}

class _DeviceTypeBoxState extends State<DeviceTypeBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 90,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: widget.isActive ? Colors.black : Colors.grey[200],
            ),
            height: 90.0,
            width: 100,
            child: Icon(
              widget.roomIcon,
              color: widget.isActive ? Colors.white : Colors.black,
              size: 50,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              widget.roomName,
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
