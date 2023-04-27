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

  Future<List<dynamic>> fetchLastTwoData({required String feed}) async {
    final url = Uri.parse('$baseUrl/$username/feeds/$feed/data');
    final response = await http.get(url, headers: {"X-AIO-Key": key});
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody.length > 0) {
        final lastTwoValues = jsonBody.sublist(0, jsonBody.length > 1 ? 2 : 1);
        final lastTwoData =
            lastTwoValues.map((value) => value['value']).toList();
        return lastTwoData;
      } else {
        return [];
      }
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
