import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

typedef TokenFunction = Future<http.Response> Function(String token);

class CommonRepos {
  static void reponsePrint(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      log('Response: $responseData');
    } else {
      log('Failed with status code: ${response.statusCode}');
      log('Response: ${response.body}');
    }
  }
}
