/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'package:flutter/services.dart';

class Pool {
  static const MethodChannel _channel =
      const MethodChannel('AriesFlutterMobileAgent');
  static Future<dynamic> createPool(String poolConfig) async {
    try {
      var response = await _channel.invokeMethod(
        'createPoolLedgerConfig',
        <String, dynamic>{
          'poolConfig': poolConfig,
        },
      );
      return response;
    } catch (exception) {
      throw exception;
    }
  }
}
