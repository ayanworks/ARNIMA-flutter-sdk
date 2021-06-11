/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'dart:convert';

import 'package:AriesFlutterMobileAgent/Protocols/Credential/CredentialInterface.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Credential/CredentialMessages.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Credential/CredentialState.dart';
import 'package:AriesFlutterMobileAgent/Utils/Helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../AriesAgent.dart';
import '../../NetworkServices/Network.dart';
import '../../Storage/DBHelper.dart';
import '../../Storage/DBModels.dart';
import '../Connection/ConnectionInterface.dart';

const MethodChannel channel = const MethodChannel('AriesFlutterMobileAgent');

class CredentialService {
  static Future<bool> sendCredentialProposal(
    String configJson,
    String credentialsJson,
    dynamic credentialProposal,
    String connectionId,
    String schemaId,
    String credDefId,
    String issuerDid,
  ) async {
    try {
      ConnectionData connection = await DBServices.getConnection(connectionId);

      Connection connectionValues =
          Connection.fromJson(jsonDecode(connection.connection));

      var credentialProposalMsg = credentialProposalMessage(
        credentialProposal,
        schemaId,
        credDefId,
        issuerDid,
      );

      Credential issuecredential = Credential(
        connectionId: connection.connectionId,
        state: CredentialState.STATE_REQUEST_SENT.state,
        credentialDefinitionId: credDefId,
        theirLabel: connectionValues.theirLabel,
        schemaId: schemaId,
        createdAt: new DateTime.now().toString(),
        updatedAt: new DateTime.now().toString(),
      );

      if (credentialProposalMsg != null) {
        var outboundMessage =
            createOutboundMessage(connectionValues, credentialProposalMsg);

        var outboundPackMessage =
            await packMessage(configJson, credentialsJson, outboundMessage);

        await outboundAgentMessagePost(
          jsonDecode(outboundMessage)['endpoint'],
          outboundPackMessage,
        );
        await DBServices.storeIssuecredential(
          CredentialData(
            connectionId: connectionValues.verkey,
            credentialId: '',
            issuecredential: jsonEncode(issuecredential),
            issuecredentialId: credentialProposalMsg['@id'],
          ),
        );
        return true;
      } else {
        return false;
      }
    } catch (exception) {
      print("exception in sendCredentialProposalsendCredentialProposal" +
          exception);
      throw exception;
    }
  }

  static Future<bool> createCredentialRequest(
    InboundMessage inboundMessage,
  ) async {
    try {
      WalletData sdkDB = await DBServices.getUserData();

      ConnectionData connection =
          await DBServices.getConnection(inboundMessage.recipientVerkey);

      Connection connectionValues =
          Connection.fromJson(jsonDecode(connection.connection));
      var message = inboundMessage.message;

      var offersAttach = jsonDecode(jsonEncode(message['offers~attach']));

      var credOfferJson =
          await jsonDecode(decodeBase64(offersAttach[0]['data']['base64']));

      var credDefJson = await channel.invokeMethod(
        'getCredDef',
        <String, dynamic>{
          'submitterDid': connectionValues.did,
          'credId': credOfferJson['cred_def_id']
        },
      );

      var credentialRequest = await channel.invokeMethod(
        'proverCreateCredentialReq',
        <String, dynamic>{
          'configJson': sdkDB.walletConfig,
          'credentialJson': sdkDB.walletCredentials,
          'proverDid': connectionValues.did,
          'credentialOfferJson': jsonEncode(credOfferJson),
          'credentialDefJson': credDefJson,
          'masterSecretId': await DBServices.getMasterSecretId()
        },
      );

      if (!message.containsKey('~thread')) {
        throw new ErrorDescription('Thread is not present!');
      }

      var thread = jsonDecode(jsonEncode(message['~thread']));

      String threadId;
      if (thread != null) {
        threadId = message['@id'];
      } else {
        threadId = message['~thread']['thid'];
      }

      Credential issuecredential = new Credential(
        connectionId: connection.connectionId,
        state: CredentialState.STATE_ISSUED.state,
        credentialDefinitionId: credOfferJson['cred_def_id'],
        theirLabel: connectionValues.theirLabel,
        threadId: threadId,
        schemaId: credOfferJson['schema_id'],
        credentialOffer: jsonEncode(credOfferJson),
        credDefJson: credDefJson,
        credentialRequest: credentialRequest[0],
        credentialRequestMetadata: credentialRequest[1],
        rawCredential: jsonEncode(
          message['credential_preview'],
        ),
      );

      if (thread.length > 0) {
        issuecredential.updatedAt = new DateTime.now().toString();
      } else {
        issuecredential.createdAt = new DateTime.now().toString();
      }

      var credentialRequestMessage = await createRequestCredentialMessage(
        credentialRequest[0],
        '',
        threadId,
      );

      var outboundMessage = createOutboundMessage(
        connectionValues,
        jsonEncode(credentialRequestMessage),
      );

      var outboundPackMessage = await packMessage(
        sdkDB.walletConfig,
        sdkDB.walletCredentials,
        outboundMessage,
      );

      await outboundAgentMessagePost(
        jsonDecode(outboundMessage)['endpoint'],
        outboundPackMessage,
      );

      await DBServices.storeIssuecredential(
        CredentialData(
          connectionId: connectionValues.verkey,
          credentialId: '',
          issuecredential: jsonEncode(issuecredential),
          issuecredentialId: threadId,
        ),
      );

      return true;
    } catch (exception) {
      print('Catch in createCredentialRequest : $exception ');
      throw exception;
    }
  }

  static receiveCredential(
    String messageId,
    InboundMessage inboundMessage,
  ) async {
    try {
      ConnectionData connection =
          await DBServices.getConnection(inboundMessage.recipientVerkey);

      Connection connectionValues =
          Connection.fromJson(jsonDecode(connection.connection));

      if (connection.connectionId.isEmpty) {
        throw ErrorDescription(
            'Connection for verKey ${inboundMessage.recipientVerkey} not found!');
      }

      var message = jsonDecode(inboundMessage.message);

      var thread = jsonDecode(jsonEncode(message['~thread']));

      String threadId;
      if (thread != null) {
        threadId = message['@id'];
      } else {
        threadId = message['~thread']['thid'];
      }

      Credential issuecredential = new Credential(
        connectionId: connection.connectionId,
        theirLabel: connectionValues.theirLabel,
        threadId: threadId,
        rawCredential: jsonEncode(message['credential_preview']),
        state: CredentialState.STATE_REQUEST_RECEIVED.state,
        credentialDefinitionId: '',
      );

      await DBServices.storeIssuecredential(
        CredentialData(
          connectionId: connectionValues.verkey,
          credentialId: '',
          issuecredential: jsonEncode(issuecredential),
          issuecredentialId: threadId,
        ),
      );

      inboundMessage.message = message;

      await DBServices.saveMessages(
        MessageData(
          auto: false,
          isProcessed: true,
          messageId: messageId + '',
          messages: jsonEncode(inboundMessage),
          thId: threadId,
          connectionId: inboundMessage.recipientVerkey,
        ),
      );
      return connectionValues;
    } catch (exception) {
      print('thrown error from reciveCredential::: $exception');
      throw exception;
    }
  }

  static Future<bool> storeCredential(InboundMessage inboundMessage) async {
    try {
      ConnectionData connection =
          await DBServices.getConnection(inboundMessage.recipientVerkey);

      Connection connectionValues =
          Connection.fromJson(jsonDecode(connection.connection));

      if (connection.connectionId.isEmpty) {
        throw ErrorDescription(
            'Connection for verKey ${inboundMessage.recipientVerkey} not found!');
      }

      var messageObject = jsonDecode(inboundMessage.message);

      var issuecredentialRecordDB =
          await DBServices.getissuecredential(messageObject['~thread']['thid']);

      var issuecredentialRecord =
          jsonDecode(issuecredentialRecordDB.issuecredential);

      var credentialsAttach = messageObject['credentials~attach'];

      var credCertificate = await jsonDecode(
          decodeBase64(credentialsAttach[0]['data']['base64']));

      var revocRegDefJson;

      if (credCertificate.containsKey('rev_reg_id') &&
          credCertificate['rev_reg_id'] != null) {
        revocRegDefJson = await channel.invokeMethod(
            'getRevocRegDef', <String, dynamic>{
          'submitterDid': connectionValues.did,
          'ID': credCertificate['rev_reg_id']
        });
      }

      WalletData userData = await DBServices.getUserData();

      var storedCredentialId =
          await channel.invokeMethod('proverStoreCredential', <String, dynamic>{
        'configJson': userData.walletConfig,
        'credentialJson': userData.walletCredentials,
        'credId': null,
        'credReqMetadataJson':
            issuecredentialRecord['credentialRequestMetadata'],
        'credJson': jsonEncode(credCertificate),
        'credDefJson': issuecredentialRecord['credDefJson'],
        'revRegDefJson': revocRegDefJson
      });

      if (storedCredentialId != null) {
        issuecredentialRecord['state'] = CredentialState.STATE_ACKED.state;
        issuecredentialRecord['revocRegId'] = credCertificate['rev_reg_id'];
        if (revocRegDefJson != null) {
          issuecredentialRecord['revocRegDefJson'] =
              jsonDecode(revocRegDefJson);
        } else {
          issuecredentialRecord['revocRegDefJson'] = null;
        }
        issuecredentialRecord['updatedAt'] = new DateTime.now().toString();
        issuecredentialRecord['credentialId'] = storedCredentialId;
      } else {
        throw ErrorDescription('Credential not able to store in your wallet');
      }
      var credentialRequestMessage =
          storedCredentialAckMessage(messageObject['~thread']['thid']);

      var outboundMessage = createOutboundMessage(
          connectionValues, jsonEncode(credentialRequestMessage));

      var outboundPackMessage = await packMessage(
        userData.walletConfig,
        userData.walletCredentials,
        outboundMessage,
      );

      await outboundAgentMessagePost(
        jsonDecode(outboundMessage)['endpoint'],
        outboundPackMessage,
      );

      await DBServices.storeIssuecredential(
        CredentialData(
          connectionId: issuecredentialRecordDB.connectionId,
          credentialId: storedCredentialId,
          issuecredential: jsonEncode(issuecredentialRecord),
          issuecredentialId: messageObject['~thread']['thid'],
        ),
      );
      return true;
    } catch (exception) {
      throw exception;
    }
  }
}
