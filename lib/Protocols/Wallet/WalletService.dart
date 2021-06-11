/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
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
      String createWallet =
          await _channel.invokeMethod('createWallet', <String, dynamic>{
        'configJson': configJson,
        'credentialJson': credentialsJson,
      });
      if (createWallet.isNotEmpty && createWallet == 'success') {
        List<dynamic> createDidAndVerKeyResponse = await createWalletDidStore(
          configJson,
          credentialsJson,
          {},
          true,
          label,
        );
        return createDidAndVerKeyResponse;
      }
    } catch (exception) {
      throw exception;
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
      List<dynamic> responseOfMyDids =
          await _channel.invokeMethod('createAndStoreMyDids', <String, dynamic>{
        'configJson': configJson,
        'credentialJson': credentialsJson,
        'didJson': jsonEncode(didJson),
        'createMasterSecret': createMasterSecret,
      });

      if (responseOfMyDids.length > 0) {
        WalletData walletDEtails = WalletData(
          configJson,
          credentialsJson,
          label,
          responseOfMyDids[0],
          responseOfMyDids[1],
          responseOfMyDids[2],
          "",
          "",
        );
        await DBServices.saveWalletData(walletDEtails);
      }
      return responseOfMyDids;
    } catch (exception) {
      throw exception;
    }
  }
}
