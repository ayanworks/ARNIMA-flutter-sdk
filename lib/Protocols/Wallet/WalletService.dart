import 'dart:convert';

import 'package:AriesFlutterMobileAgent/Storage/DBModels.dart';
import 'package:flutter/services.dart';

class WalletService {
  static const MethodChannel _channel =
      const MethodChannel('AriesFlutterMobileAgent');

  static Future createWallet(
    String configJson,
    String credentialsJson,
    String label,
  ) async {
    try {
      final String createWallet =
          await _channel.invokeMethod('createWallet', <String, dynamic>{
        'configJson': configJson,
        'credentialJson': credentialsJson,
      });
      print(createWallet);
      List<dynamic> createDidAndVerKeyResponse = await createWalletDidStore(
        configJson,
        credentialsJson,
        {},
        true,
        label,
      );
      return createDidAndVerKeyResponse;
    } catch (err) {
      print("Error in createWallet $err");
      throw err;
    }
  }

  static Future<List<dynamic>> createWalletDidStore(
    String configJson,
    String credentialsJson,
    Object didJson,
    bool createMasterSecret,
    String label,
  ) async {
    try {
      final List<dynamic> handle =
          await _channel.invokeMethod('createAndStoreMyDids', <String, dynamic>{
        'configJson': configJson,
        'credentialJson': credentialsJson,
        'didJson': jsonEncode(didJson),
        'createMasterSecret': createMasterSecret,
      });
      if (handle.length > 0) {
        await DBServices.saveWalletData(
          WalletData(
            configJson,
            credentialsJson,
            label,
            handle[0],
            handle[1],
            handle[2],
            "",
            "",
          ),
        );
      }
      return handle;
    } catch (err) {
      print("Error in Agent $err");
      throw err;
    }
  }
}
