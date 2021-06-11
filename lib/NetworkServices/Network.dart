/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<dynamic> postData(String url, String apiBody) async {
  try {
    var response = await http.post(
      url,
      body: apiBody,
      headers: {
        "Accept": 'application/json',
        'Content-Type': 'application/json',
      },
    );
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    return responseJson;
  } catch (exception) {
    throw exception;
  }
}

Future<dynamic> getData(String url) async {
  try {
    var response = await http.get(
      url,
      headers: {
        "Accept": 'application/json',
        'Content-Type': 'application/json',
      },
    );

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    return responseJson;
  } catch (exception) {
    throw exception;
  }
}

Future<dynamic> outboundAgentMessagePost(
  String url,
  Object apiBody,
) async {
  try {
    final response = await http.post(
      url,
      body: apiBody,
      headers: {
        "Accept": 'application/json',
        'Content-Type': 'application/ssi-agent-wire',
      },
    );
    return response;
  } catch (exception) {
    throw exception;
  }
}
