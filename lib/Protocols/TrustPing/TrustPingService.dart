/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'dart:convert';

import 'package:AriesFlutterMobileAgent/NetworkServices/Network.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionInterface.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionStates.dart';
import 'package:AriesFlutterMobileAgent/Storage/DBModels.dart';
import 'package:AriesFlutterMobileAgent/Utils/Helpers.dart';
import 'package:AriesFlutterMobileAgent/Utils/utils.dart';

import 'TrustPingMessages.dart';
import 'TrustPingState.dart';

class TrustPingService {
  static Future<bool> sendTrustPingResponse(String connectionId) async {
    try {
      ConnectionData connectionDB =
          await DBServices.getConnection(connectionId);
      var connection = jsonDecode(connectionDB.connection);
      var trustPingMessage = createTrustPingMessage();
      TrustPingData trustPing = TrustPingData(
        connectionDB.connectionId,
        jsonDecode(trustPingMessage)['@id'],
        jsonEncode(trustPingMessage),
        TrustPingState.SENT.state,
      );
      WalletData sdkDB = await DBServices.getWalletData();
      Map<String, dynamic> outboundMessage =
          createOutboundMessage(connection, trustPingMessage);
      var outboundPackMessage = await packMessage(
          sdkDB.walletConfig, sdkDB.walletCredentials, outboundMessage);

      await outboundAgentMessagePost(
        outboundMessage['endpoint'],
        jsonEncode(outboundPackMessage),
      );
      await DBServices.storeTrustPing(trustPing);
      return true;
    } catch (exception) {
      print('exception in sendTrustPingResponse $exception');
      throw exception;
    }
  }

  static saveTrustPingResponse(InboundMessage inboundMessage) async {
    try {
      ConnectionData connectionDB =
          await DBServices.getConnection(inboundMessage.recipientVerkey);
      Connection connection =
          Connection.fromJson(jsonDecode(connectionDB.connection));
      var message = jsonDecode(inboundMessage.message);
      var trustPingId = message['~thread']['thid'];
      TrustPingData trustPing = TrustPingData(
        '',
        trustPingId,
        '',
        TrustPingState.ACTIVE.state,
      );
      await DBServices.storeTrustPing(trustPing);
      return connection;
    } catch (exception) {
      print('exception in saveTrustPingResponse $exception');
      throw exception;
    }
  }

  static processPing(
    String configJson,
    String credentialsJson,
    InboundMessage inboundMessage,
  ) async {
    try {
      ConnectionData connectionDB =
          await DBServices.getConnection(inboundMessage.recipientVerkey);
      var connection = jsonDecode(connectionDB.connection);
      var parsedMessage = jsonDecode(inboundMessage.message);
      if (connection.state != ConnectionStates.COMPLETE.state) {
        connection.state = ConnectionStates.COMPLETE.state;
        connection.updatedAt = new DateTime.now();
      }
      ConnectionData storeDataintoDB =
          ConnectionData(connectionDB.connectionId, jsonEncode(connection));

      if (parsedMessage['response_requested']) {
        var reply = createTrustPingResponseMessage(parsedMessage['@id']);
        Map<String, dynamic> outboundMessage =
            createOutboundMessage(connection, reply);
        var outboundPackMessage = await packMessage(
          configJson,
          credentialsJson,
          outboundMessage,
        );
        await outboundAgentMessagePost(
          outboundMessage['endpoint'],
          jsonEncode(outboundPackMessage),
        );
      }
      await DBServices.updateConnection(storeDataintoDB);
      return connection;
    } catch (exception) {
      print('exception in processPing $exception');
      throw exception;
    }
  }
}
