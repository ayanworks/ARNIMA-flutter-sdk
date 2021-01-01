import 'dart:async';
import 'dart:convert';
import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionInterface.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionService.dart';
import 'package:AriesFlutterMobileAgent/Protocols/TrustPing/TrustPingService.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Wallet/WalletService.dart';
import 'package:AriesFlutterMobileAgent/Storage/DBModels.dart';
import 'package:AriesFlutterMobileAgent/Utils/utils.dart';
import 'package:hive/hive.dart';
import '../Protocols/ConnectWithMediator/ConnectWithMediatorService.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:socket_io_client/socket_io_client.dart' as IO;

StreamController<String> controller = StreamController<String>();

class AriesFlutterMobileAgent {
  static Future<void> init() async {
    try {
      final appDocumentDirectory =
          await path_provider.getApplicationDocumentsDirectory();
      print('appDocumentDirectory $appDocumentDirectory ');
      Hive.init(appDocumentDirectory.path);
      Hive.registerAdapter(WalletDataAdapter());
      Hive.registerAdapter(ConnectionDataAdapter());
      Hive.registerAdapter(MessageDataAdapter());
      Hive.registerAdapter(TrustPingDataAdapter());
      AriesFlutterMobileAgent.eventListener();
    } catch (err) {
      print('err init $err');
    }
  }

  static Future<WalletData> getWalletData() async {
    try {
      Box<WalletData> _wallet;
      if (_wallet == null || !_wallet.isOpen) {
        _wallet = await Hive.openBox('wallet');
      } else {
        _wallet = Hive.box('wallet');
      }
      WalletData walletData = _wallet.get(0);
      return walletData;
    } catch (exc) {
      print("exccc $exc");
      return null;
    }
  }

  static Future<List<dynamic>> createWallet(
    Object configJson,
    Object credentialsJson,
    String label,
  ) async {
    try {
      final List<dynamic> response = await WalletService.createWallet(
        jsonEncode(configJson),
        jsonEncode(credentialsJson),
        label,
      );
      return response;
    } catch (err) {
      print("Error in Agent $err");
      throw err;
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
      print(agentRegResponse);
      return agentRegResponse;
    } catch (err) {
      print("Error in Agent $err");
      throw err;
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
    } catch (error) {
      print("Error in createInvitation $error");
      throw error;
    }
  }

  static Future acceptInvitation(
    Object didJson,
    String message,
  ) async {
    try {
      print("In Accept Invitation AriesFlutterMobileAgent.dart");
      var user = await DBServices.getWalletData();
      Object invitation = decodeInvitationFromUrl(message);
      var acceptInvitationResponse = await ConnectionService.acceptInvitation(
        user.walletConfig,
        user.walletCredentials,
        didJson,
        invitation,
      );
      print("acceptInvitationResponse in Agent $acceptInvitationResponse");
      return acceptInvitationResponse;
    } catch (err) {
      print("Error in acceptInvitation $err");
      throw err;
    }
  }

  static Future socketInit() async {
    String url = await DBServices.getServiceEndpoint();
    print('mediator url $url');
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
    print('User verKey from SocketEmit:${user.verkey}');
    socket.emit('message', user.verkey);
    print('socket emit complete');
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
      print("object $apiBody");
      socket.emit('receiveAcknowledgement', apiBody);
      controller.add('preparedResponseforInboundMessage');
    }
  }

  static Future eventListener() async {
    Stream stream = controller.stream;
    stream.listen((event) async {
      if (event == "") {
        print("empty");
        return;
      }
      if (event == 'preparedResponseforInboundMessage') {
        print('Inside IF prePareResponseInboundMessage');
        var user = await DBServices.getWalletData();

        List<MessageData> dbMessages =
            await DBServices.getAllUnprocessedMessages();

        for (int i = 0; i < dbMessages.length; i++) {
          if (dbMessages[i].auto) {
            jsonDecode(dbMessages[i].messages);

            Map<String, dynamic> messageRecord = new Map<String, dynamic>.from(
                jsonDecode(dbMessages[i].messages));
            var msg = messageRecord['msg'];
            var unPackMessageResponse = await unPackMessage(
              user.walletConfig,
              user.walletCredentials,
              msg,
            );
            Map<String, dynamic> message = jsonDecode(unPackMessageResponse);

            Map<String, dynamic> messageValues = jsonDecode(message['message']);
            print('message:::::${messageValues['@type']}');
            switch (messageValues['@type']) {
              case MessageType.ConnectionResponse:
                try {
                  print('InSide response123');
                  var isCompleted = await ConnectionService.acceptResponse(
                    user.walletConfig,
                    user.walletCredentials,
                    InboundMessage(
                      message['sender_verkey'],
                      message['recipient_verkey'],
                      message['message'],
                    ),
                  );
                  if (isCompleted == true) {
                    await DBServices.removeMessage(dbMessages[i].messageId);
                  } else {
                    print('isCompleted:$isCompleted');
                  }
                } catch (error) {
                  print(
                      'preparedResponseforInboundMessage  ConnectionResponse$error');
                }
                break;
              case MessageType.ConnectionRequest:
                try {
                  print('InSide ConnectionRequest');
                  var isCompleted = await ConnectionService.acceptRequest(
                    user.walletConfig,
                    user.walletCredentials,
                    InboundMessage(
                      message['sender_verkey'],
                      message['recipient_verkey'],
                      message['message'],
                    ),
                  );
                  if (isCompleted == true) {
                    await DBServices.removeMessage(dbMessages[i].messageId);
                  }
                } catch (error) {
                  print(
                      'preparedResponseforInboundMessage  ConnectionRequest$error');
                }
                break;
              case MessageType.TrustPingMessage:
                try {
                  print('InSide TrustPingMessage');
                  Connection connection = await TrustPingService.processPing(
                    user.walletConfig,
                    user.walletCredentials,
                    InboundMessage(
                      message['sender_verkey'],
                      message['recipient_verkey'],
                      message['message'],
                    ),
                  );
                  if (connection != null) {
                    await DBServices.removeMessage(dbMessages[i].messageId);
                  }
                } catch (error) {
                  print('TrustPingMessage err$error');
                }
                break;
              case MessageType.TrustPingResponseMessage:
                var connection = await TrustPingService.saveTrustPingResponse(
                  InboundMessage(
                    message['sender_verkey'],
                    message['recipient_verkey'],
                    message['message'],
                  ),
                );
                if (connection != null) {
                  await DBServices.removeMessage(dbMessages[i].messageId);
                }
                break;
              default:
                print('In Default Case, ${messageValues['@type']}');
            }
          } else {
            print("Auto:$dbMessages[i].auto");
          }
        }
      }
      print("Event name $event");
    });
  }

  static Future socketListener(socket) async {
    socket.on("message", (data) async {
      var inboxId = '';
      if (data.length > 0) {
        print("Message from MD:$data");
        data
            .map(
              (message) => {
                print('item $message'),
                inboxId = inboxId + message['id'].toString() + ",",
                DBServices.saveMessages(
                  MessageData(
                    message['id'].toString() + '',
                    jsonEncode(message['message']),
                    true,
                    false,
                  ),
                )
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
}
