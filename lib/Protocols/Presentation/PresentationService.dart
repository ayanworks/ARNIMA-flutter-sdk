/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'dart:convert';

import 'package:AriesFlutterMobileAgent/NetworkServices/Network.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionInterface.dart';
import 'package:AriesFlutterMobileAgent/Storage/DBModels.dart';
import 'package:AriesFlutterMobileAgent/Utils/utils.dart';

import '../../Storage/DBModels.dart';
import 'PresentationInterface.dart';
import 'PresentationMessages.dart';
import 'PresentationState.dart';

class PresentationService {
  static Future<dynamic> receivePresentProofRequest(
    String messageId,
    InboundMessage inboundMessage,
  ) async {
    try {
      ConnectionData connectionDB =
          await DBServices.getConnection(inboundMessage.recipientVerkey);
      Connection connection =
          Connection.fromJson(jsonDecode(connectionDB.connection));
      var message = jsonDecode(inboundMessage.message);
      var presentationRequest = message['request_presentations~attach'];
      var proofRequest = decodeBase64(presentationRequest[0]['data']['base64']);

      Presentation presentproofRecord = new Presentation(
        connectionId: connectionDB.connectionId,
        theirLabel: connection.theirLabel,
        threadId: message['@id'],
        presentationRequest: proofRequest,
        state: PresentationState.STATE_PRESENTATION_RECEIVED.state,
        createdAt: new DateTime.now().toString(),
        updatedAt: new DateTime.now().toString(),
      );

      await DBServices.storePresentation(
        PresentationData(
          message['@id'],
          connection.verkey,
          jsonEncode(presentproofRecord),
        ),
      );

      inboundMessage.message = message;

      MessageData messageData = new MessageData(
        auto: false,
        connectionId: inboundMessage.recipientVerkey,
        isProcessed: true,
        messageId: messageId + '',
        messages: jsonEncode(inboundMessage),
        thId: message['@id'],
      );
      await DBServices.saveMessages(messageData);
      return connection;
    } catch (exception) {
      print("Err in receivePresentProofRequest$exception");
      throw exception;
    }
  }

  static Future<bool> createPresentProofRequest(
      InboundMessage inboundMessage) async {
    try {
      WalletData sdkDB = await DBServices.getWalletData();
      ConnectionData connectionDB =
          await DBServices.getConnection(inboundMessage.recipientVerkey);
      Connection connection =
          Connection.fromJson(jsonDecode(connectionDB.connection));

      var message = inboundMessage.message;

      var presentationRequest = message['request_presentations~attach'];

      var proofRequest =
          jsonDecode(decodeBase64(presentationRequest[0]['data']['base64']));

      var presentation = await channel.invokeMethod(
        'proverSearchCredentialsForProofReq',
        <String, dynamic>{
          'configJson': sdkDB.walletConfig,
          'credentialJson': sdkDB.walletCredentials,
          'proofRequest': jsonEncode(proofRequest),
          'did': sdkDB.publicDid,
          'masterSecretId': sdkDB.masterSecretId,
        },
      );
      //212

      Presentation presentproofRecord = Presentation(
        connectionId: connectionDB.connectionId,
        theirLabel: connection.theirLabel,
        threadId: message['@id'],
        presentationRequest: jsonEncode(proofRequest),
        presentation: jsonEncode(presentation),
        state: PresentationState.STATE_PRESENTATION_SENT.state,
        createdAt: new DateTime.now().toString(),
        updatedAt: new DateTime.now().toString(),
      );

      var creatPresentationMessageObject = createPresentationMessage(
        presentation,
        '',
        message['@id'],
      );

      var outboundMessage = createOutboundMessage(
          connection, jsonEncode(creatPresentationMessageObject));
      var outboundPackMessage = await packMessage(
        sdkDB.walletConfig,
        sdkDB.walletCredentials,
        outboundMessage,
      );
      await outboundAgentMessagePost(
        jsonDecode(outboundMessage)['endpoint'],
        outboundPackMessage,
      );

      await DBServices.storePresentation(
        PresentationData(
          message['@id'],
          connection.verkey,
          jsonEncode(presentproofRecord),
        ),
      );
      return true;
    } catch (exception) {
      print("Exception in createPresentProofRequest $exception");
      throw exception;
    }
  }
}
