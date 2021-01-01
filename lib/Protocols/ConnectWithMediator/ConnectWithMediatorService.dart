import 'dart:convert';

import 'package:AriesFlutterMobileAgent/AriesAgent.dart';
import 'package:AriesFlutterMobileAgent/Utils/Helpers.dart';
import '../../Pool/Pool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ConnectWithMediatorService {
  Type get runtimeType => String;

  static const MethodChannel _channel =
      const MethodChannel('AriesFlutterMobileAgent');

  static Future<bool> connectWithMediator(
    String url,
    String apiBody,
    String configJson,
    String credentialJson,
    String poolConfig,
  ) async {
    try {
      var incomingRouterResponse = await postData(url, apiBody);
      print(
        "incomingRouterResponse ${incomingRouterResponse['data']['serviceEndpoint']}",
      );
      print(
        "configJson ${configJson.runtimeType}",
      );
      var user = await DBServices.getWalletData();
      await DBServices.updateWalletData(
        WalletData(
          user.walletConfig,
          user.walletCredentials,
          user.label,
          user.publicDid,
          user.verkey,
          user.masterSecretId,
          incomingRouterResponse['data']['serviceEndpoint'],
          incomingRouterResponse['data']['routingKeys'][0],
        ),
      );

      var createPoolResponse = await Pool.createPool(poolConfig);
      if (!createPoolResponse) {
        throw false;
      }
      WalletData myWallet = await AriesFlutterMobileAgent.getWalletData();
      print("i am in routingKey ${myWallet.label}");
      var walletRecord = {
        'label': myWallet.label,
        'serviceEndpoint': myWallet.serviceEndpoint,
        'routingKey': myWallet.routingKey,
        'publicDid': myWallet.publicDid,
        'verKey': myWallet.verkey,
        'masterSecretId': myWallet.masterSecretId,
        'poolConfig': poolConfig,
      };

      final bool addRecordResponse = await _channel.invokeMethod(
        'addWalletRecord',
        <String, dynamic>{
          'configJson': configJson,
          'credentialJson': credentialJson,
          'type': describeEnum(RecordType.MediatorAgent),
          'id': '1',
          'value': jsonEncode(walletRecord),
          'tags': '{}',
        },
      );

      print("add record response $addRecordResponse");
      if (addRecordResponse == true) {
        return true;
      } else {
        throw false;
      }
    } catch (err) {
      print("error in AgentRegistration $err");
      throw err;
    }
  }
}
