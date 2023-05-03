import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdafruitDataService extends ChangeNotifier {
  String baseUrl = "https://io.adafruit.com/api/v2";
  String username;
  String key;
  AdafruitDataService(this.username, this.key);

  Future<dynamic> fetchData({required String feed}) async {
    final url = Uri.parse('$baseUrl/$username/feeds/$feed/data/last');
    final response = await http.get(url, headers: {"X-AIO-Key": key});
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return jsonBody['value'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> sendData(
      {required String feed, required String dataValue}) async {
    final url = Uri.parse('$baseUrl/$username/feeds/$feed/data');
    await http
        .post(url, headers: {"X-AIO-Key": key}, body: {"value": dataValue});
    notifyListeners();
  }
}
