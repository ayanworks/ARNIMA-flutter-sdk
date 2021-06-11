/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'dart:async';
import 'dart:convert';
import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionInterface.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionService.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Credential/CredentialService.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Presentation/PresentationService.dart';
import 'package:AriesFlutterMobileAgent/Protocols/TrustPing/TrustPingService.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Wallet/WalletService.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Protocols/ConnectWithMediator/ConnectWithMediatorService.dart';
import '../Storage/DBModels.dart';
import '../Utils/utils.dart';
import 'package:eventify/eventify.dart';

StreamController<String> controller = StreamController<String>();
EventEmitter emitterAriesSdk = new EventEmitter();

class AriesFlutterMobileAgent {
  static Future<void> init() async {
    try {
      final appDocumentDirectory =
          await path_provider.getApplicationDocumentsDirectory();
      Hive.init(appDocumentDirectory.path);
      Hive.registerAdapter(WalletDataAdapter());
      Hive.registerAdapter(ConnectionDataAdapter());
      Hive.registerAdapter(MessageDataAdapter());
      Hive.registerAdapter(TrustPingDataAdapter());
      Hive.registerAdapter(CredentialDataAdapter());
      Hive.registerAdapter(PresentationDataAdapter());
      controller.add('preparedResponseforInboundMessage');
      AriesFlutterMobileAgent.eventListener();
    } catch (exception) {
      throw exception;
    }
  }

  static Future<List<dynamic>> createWallet(
    Object configJson,
    Object credentialsJson,
    String label,
  ) async {
    try {
      List<dynamic> response = await WalletService.createWallet(
        jsonEncode(configJson),
        jsonEncode(credentialsJson),
        label,
      );
      return response;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<WalletData> getWalletData() async {
    try {
      WalletData walletData = await DBServices.getWalletData();
      return walletData;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<bool> connectWithMediator(
    String url,
    String apiBody,
    String poolConfig,
  ) async {
    try {
      WalletData user = await DBServices.getWalletData();
      var agentRegResponse =
          await ConnectWithMediatorService.connectWithMediator(
        url,
        apiBody,
        user.walletConfig,
        user.walletCredentials,
        poolConfig,
      );
      return agentRegResponse;
    } catch (exception) {
      print("Exception to connect mediator $exception");
      throw exception;
    }
  }

  static Future<List<MessageData>> getAllActionMessages() async {
    try {
      List<MessageData> messageList = await DBServices.getAllActionMessages();
      return messageList;
    } catch (exception) {
      print("Exception getAllConnections $exception");
      throw exception;
    }
  }

  static Future<MessageData> getActionMessagesById(String threadId) async {
    try {
      MessageData messageData =
          await DBServices.getActionMessagesById(threadId);
      return messageData;
    } catch (exception) {
      print("Exception getAllActionMessagesById $exception");
      throw exception;
    }
  }

  static Future createInvitation(Object didJson) async {
    try {
      WalletData user = await DBServices.getWalletData();
      var response = await ConnectionService.createInvitation(
        user.walletConfig,
        user.walletCredentials,
        didJson,
      );
      return response;
    } catch (exception) {
      print("Exception in createInvitation $exception");
      throw exception;
    }
  }

  static Future acceptInvitation(
    Object didJson,
    String message,
  ) async {
    try {
      WalletData user = await DBServices.getWalletData();
      Object invitation = decodeInvitationFromUrl(message);
      var acceptInvitationResponse = await ConnectionService.acceptInvitation(
        user.walletConfig,
        user.walletCredentials,
        didJson,
        invitation,
      );
      return acceptInvitationResponse;
    } catch (exception) {
      print("Exception in acceptInvitation $exception");
      throw exception;
    }
  }

  static Future<List<ConnectionData>> getAllConnections() async {
    try {
      List<ConnectionData> connectionList =
          await DBServices.getAllConnections();
      return connectionList;
    } catch (exception) {
      print("Error getAllConnections $exception");
      throw exception;
    }
  }

  static Future sendCredentialProposal(
    connectionId,
    credentialProposal,
    schemaId,
    credDefId,
    issuerDid,
  ) async {
    try {
      WalletData sdkDB = await DBServices.getWalletData();
      var sendCredentialProposal =
          await CredentialService.sendCredentialProposal(
        sdkDB.walletConfig,
        sdkDB.walletCredentials,
        connectionId,
        credentialProposal,
        schemaId,
        credDefId,
        issuerDid,
      );
      return sendCredentialProposal;
    } catch (exception) {
      print('Exception in send credential praposal = ' + exception);
      throw exception;
    }
  }

  static Future<List<CredentialData>> getAllCredentials() async {
    try {
      List<CredentialData> credentialList =
          await DBServices.getAllCredentials();
      return credentialList;
    } catch (exception) {
      print("Error getAllCredentials $exception");
      throw exception;
    }
  }

  static Future acceptCredentialOffer(String messageId, dynamic message) async {
    try {
      InboundMessage inboundMessage = InboundMessage.fromJson(
        jsonDecode(message),
      );
      bool response =
          await CredentialService.createCredentialRequest(inboundMessage);
      if (response) {
        await DBServices.removeMessage(messageId);
      }
    } catch (exception) {
      print("Exception in acceptCredentialOffer $exception");
      throw exception;
    }
  }

  static Future listAllCredentials({Object filter}) async {
    try {
      MethodChannel channel = const MethodChannel('AriesFlutterMobileAgent');
      WalletData sdkDB = await DBServices.getUserData();
      var getCredentials = await channel.invokeMethod(
        'proverGetCredentials',
        <String, dynamic>{
          'configJson': sdkDB.walletConfig,
          'credentialJson': sdkDB.walletCredentials,
          'filter': jsonEncode(filter),
        },
      );
      return jsonDecode(getCredentials);
    } catch (exception) {
      print("Exception in list of all credential from wallet =  $exception");
      throw exception;
    }
  }

  static Future<List<PresentationData>> getPresentationByConnectionId(
      String recipientVerkey) async {
    try {
      List<PresentationData> presentationList =
          await DBServices.getPresentationByConnectionId(recipientVerkey);
      return presentationList;
    } catch (exception) {
      print("Error getPresentationByConnectionId $exception");
      throw exception;
    }
  }

  static Future sendProof(String messageId, dynamic message) async {
    try {
      InboundMessage inboundMessage = InboundMessage.fromJson(
        jsonDecode(message),
      );
      bool response =
          await PresentationService.createPresentProofRequest(inboundMessage);
      if (response) {
        await DBServices.removeMessage(messageId);
      }
    } catch (exception) {
      print("Exception in sendProof $exception");
      throw exception;
    }
  }

  static Future socketInit() async {
    String url = await DBServices.getServiceEndpoint();
    IO.Socket socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'reconnection': true,
      'autoConnect': true,
    });
    if (socket == null || (socket != null && socket.disconnected)) {
      socket.connect();
      await socketListener(socket);
      await socketEmit(socket);
    } else if (socket.connected) {
      await socketEmit(socket);
    }
    socket.on('disconnect', (reason) {
      if (reason == 'io server disconnect') {
        socket.connect();
      }
    });
  }

  static Future socketEmit(socket) async {
    var user = await DBServices.getWalletData();
    socket.emit('message', user.verkey);
  }

  static Future emitMessageIdForAcknowledgement(
    int msgLength,
    String inboxId,
    socket,
  ) async {
    if (msgLength > 0) {
      var user = await DBServices.getWalletData();
      inboxId = inboxId.substring(0, inboxId.length - 1);
      var apiBody = {
        "publicKey": user.verkey,
        "inboxId": inboxId,
      };
      socket.emit('receiveAcknowledgement', apiBody);
      controller.add('preparedResponseforInboundMessage');
    }
  }

  static Future eventListener() async {
    Stream stream = controller.stream;
    stream.listen(
      (event) async {
        try {
          if (event != '' && event == 'preparedResponseforInboundMessage') {
            WalletData user = await DBServices.getWalletData();

            List<MessageData> dbMessages =
                await DBServices.getAllUnprocessedMessages();

            for (int i = 0; i < dbMessages.length; i++) {
              if (dbMessages[i].auto) {
                Map<String, dynamic> messageRecord;
                messageRecord = new Map<String, dynamic>.from(
                    jsonDecode(dbMessages[i].messages));

                var msg = messageRecord['msg'];
                var unPackMessageResponse = await unPackMessage(
                  user.walletConfig,
                  user.walletCredentials,
                  msg,
                );

                Map<String, dynamic> message =
                    jsonDecode(unPackMessageResponse);

                Map<String, dynamic> messageValues =
                    jsonDecode(message['message']);
                switch (messageValues['@type']) {
                  case MessageType.ConnectionResponse:
                    connectionRsponseType(user, message, dbMessages, i);
                    break;
                  case MessageType.ConnectionRequest:
                    connectionRequestType(user, message, dbMessages, i);
                    break;
                  case MessageType.TrustPingMessage:
                    trustPingMessageType(user, message, dbMessages, i);
                    break;
                  case MessageType.TrustPingResponseMessage:
                    trustPingMessageResponseType(user, message, dbMessages, i);
                    break;
                  case MessageType.OfferCredential:
                    offerCredentialType(user, message, dbMessages, i);
                    break;
                  case MessageType.IssueCredential:
                    issueCredentialType(user, message, dbMessages, i);
                    break;
                  case MessageType.RequestPresentation:
                    requestPresentationType(user, message, dbMessages, i);
                    break;
                  case MessageType.PresentationAck:
                    presentationAckType(user, message, dbMessages, i);
                    break;
                  default:
                    print('In Default Case, ${messageValues['@type']}');
                }
              }
            }
          }
        } catch (exception) {
          throw exception;
        }
      },
    );
  }

  static Future socketListener(socket) async {
    socket.on("message", (data) async {
      var inboxId = '';
      if (data.length > 0) {
        data
            .map(
              (message) => {
                inboxId = inboxId + message['id'].toString() + ",",
                DBServices.saveMessages(
                  MessageData(
                    auto: true,
                    isProcessed: false,
                    messageId: message['id'].toString() + '',
                    messages: message.runtimeType is String
                        ? message['message']
                        : jsonEncode(message['message']),
                  ),
                ),
              },
            )
            .toList();
        var messages = await DBServices.getMessages();
        messages.map((e) => print('objectscheck ${e.messageId}')).toList();
        emitMessageIdForAcknowledgement(data.length, inboxId, socket);
        return data;
      }
    });
  }

  static connectionRsponseType(WalletData user, Map<String, dynamic> message,
      List<MessageData> dbMessages, int i) async {
    try {
      var isCompleted = await ConnectionService.acceptResponse(
        user.walletConfig,
        user.walletCredentials,
        InboundMessage(
          message: message['message'],
          recipientVerkey: message['recipient_verkey'],
          senderVerkey: message['sender_verkey'],
        ),
      );
      if (isCompleted) {
        await DBServices.removeMessage(dbMessages[i].messageId);
      }
    } catch (exception) {
      throw exception;
    }
  }

  static connectionRequestType(WalletData user, Map<String, dynamic> message,
      List<MessageData> dbMessages, int i) async {
    try {
      var isCompleted = await ConnectionService.acceptRequest(
        user.walletConfig,
        user.walletCredentials,
        InboundMessage(
          message: message['message'],
          recipientVerkey: message['recipient_verkey'],
          senderVerkey: message['sender_verkey'],
        ),
      );
      if (isCompleted) {
        await DBServices.removeMessage(dbMessages[i].messageId);
      }
    } catch (exception) {
      throw exception;
    }
  }

  static trustPingMessageType(WalletData user, Map<String, dynamic> message,
      List<MessageData> dbMessages, int i) async {
    try {
      Connection connection = await TrustPingService.processPing(
        user.walletConfig,
        user.walletCredentials,
        InboundMessage(
          message: message['message'],
          recipientVerkey: message['recipient_verkey'],
          senderVerkey: message['sender_verkey'],
        ),
      );
      if (connection != null) {
        await DBServices.removeMessage(dbMessages[i].messageId);
      }
    } catch (exception) {
      throw exception;
    }
  }

  static trustPingMessageResponseType(WalletData user,
      Map<String, dynamic> message, List<MessageData> dbMessages, int i) async {
    var connection = await TrustPingService.saveTrustPingResponse(
      InboundMessage(
        message: message['message'],
        recipientVerkey: message['recipient_verkey'],
        senderVerkey: message['sender_verkey'],
      ),
    );
    if (connection != null) {
      await DBServices.removeMessage(dbMessages[i].messageId);
    }
    emitterAriesSdk.emit("SDKEvent", null,
        "You are now connected with ${connection.theirLabel}");
  }

  static presentationAckType(WalletData user, Map<String, dynamic> message,
      List<MessageData> dbMessages, int i) async {
    try {
      await DBServices.removeMessage(dbMessages[i].messageId);
    } catch (exception) {
      throw exception;
    }
  }

  static requestPresentationType(WalletData user, Map<String, dynamic> message,
      List<MessageData> dbMessages, int i) async {
    var connection = await PresentationService.receivePresentProofRequest(
      dbMessages[i].messageId,
      InboundMessage(
        message: message['message'],
        recipientVerkey: message['recipient_verkey'],
        senderVerkey: message['sender_verkey'],
      ),
    );
    emitterAriesSdk.emit("SDKEvent", null,
        "You have received proof request from ${connection.theirLabel}");
  }

  static issueCredentialType(WalletData user, Map<String, dynamic> message,
      List<MessageData> dbMessages, int i) async {
    bool isCompleted = await CredentialService.storeCredential(
      InboundMessage(
        message: message['message'],
        recipientVerkey: message['recipient_verkey'],
        senderVerkey: message['sender_verkey'],
      ),
    );
    if (isCompleted) {
      await DBServices.removeMessage(dbMessages[i].messageId);
    }
  }

  static offerCredentialType(WalletData user, Map<String, dynamic> message,
      List<MessageData> dbMessages, int i) async {
    var connection = await CredentialService.receiveCredential(
      dbMessages[i].messageId,
      InboundMessage(
        message: message['message'],
        recipientVerkey: message['recipient_verkey'],
        senderVerkey: message['sender_verkey'],
      ),
    );
    emitterAriesSdk.emit("SDKEvent", null,
        "You have received credential from ${connection.theirLabel}");
  }
}
