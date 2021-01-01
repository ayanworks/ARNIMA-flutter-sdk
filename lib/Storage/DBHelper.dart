import 'package:AriesFlutterMobileAgent/Storage/Models/MessageModel/messagedata.dart';
import 'package:AriesFlutterMobileAgent/Storage/Models/WalletModel/walletdata.dart';
import 'package:hive/hive.dart';

import 'DBModels.dart';

class DBServices {
  static Future<bool> saveWalletData(WalletData walletData) async {
    try {
      Box<WalletData> _wallet;
      if (_wallet == null || !_wallet.isOpen) {
        _wallet = await Hive.openBox('wallet');
      } else {
        _wallet = Hive.box('wallet');
      }
      await _wallet.add(walletData);
      return true;
    } catch (exc) {
      print("Err in save");
      return false;
    }
  }

  static Future<bool> updateWalletData(WalletData walletData) async {
    try {
      Box<WalletData> _wallet;
      if (_wallet == null || !_wallet.isOpen) {
        _wallet = await Hive.openBox('wallet');
      } else {
        _wallet = Hive.box('wallet');
      }
      await _wallet.putAt(0, walletData);
      return true;
    } catch (exc) {
      print("Err in updateWalletData");
      return false;
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

  static Future<String> getServiceEndpoint() async {
    try {
      var walletData = await getWalletData();
      String serviceEndpoint =
          walletData.serviceEndpoint.replaceFirst('/endpoint', '');
      print('serviceEndpoint $serviceEndpoint');
      return serviceEndpoint;
    } catch (exc) {
      print("exccc $exc");
      return null;
    }
  }

  static Future<bool> saveConnections(ConnectionData connections) async {
    try {
      Box _connections;
      if (_connections == null || !_connections.isOpen) {
        _connections = await Hive.openBox('connections');
      } else {
        _connections = Hive.box('connections');
      }
      print('object $connections');
      await _connections.add(connections);
      return true;
    } catch (exc) {
      print("Err in save connections $exc");
      return false;
    }
  }

  static Future<List<ConnectionData>> getAllConnections() async {
    try {
      Box _connections;
      if (_connections == null || !_connections.isOpen) {
        _connections = await Hive.openBox('connections');
      } else {
        _connections = Hive.box('connections');
      }
      List<ConnectionData> connections = [];
      for (int i = 0; i < _connections.length; i++) {
        var connectionMap = _connections.getAt(i);
        connections.add(connectionMap);
      }
      return connections;
    } catch (exc) {
      return null;
    }
  }

  static Future<ConnectionData> getConnection(String connectionId) async {
    Box _connections;
    if (_connections == null || !_connections.isOpen) {
      _connections = await Hive.openBox('connections');
    } else {
      _connections = Hive.box('connections');
    }

    var connectionRecord =
        new List<ConnectionData>.from(_connections.values.toList())
            .where((element) => element.connectionId == connectionId)
            .last;
    return connectionRecord;
  }

  static Future<bool> updateConnection(ConnectionData connection) async {
    try {
      Box _connections;
      if (_connections == null || !_connections.isOpen) {
        _connections = await Hive.openBox('connections');
      } else {
        _connections = Hive.box('connections');
      }
      List<ConnectionData> connections = await getAllConnections();
      connections.asMap().forEach((index, value) {
        if (value.connectionId == connection.connectionId) {
          _connections.putAt(index, connection);
        }
      });
      return true;
    } catch (exc) {
      print('object $exc');
      return null;
    }
  }

  static Future<bool> storeTrustPing(TrustPingData trustPing) async {
    try {
      Box _trustping;
      if (_trustping == null || !_trustping.isOpen) {
        _trustping = await Hive.openBox('trustPing');
      } else {
        _trustping = Hive.box('trustPing');
      }
      _trustping.add(trustPing);
      return true;
    } catch (exc) {
      return null;
    }
  }

  static Future<bool> saveMessages(MessageData messages) async {
    try {
      Box _messages;
      if (_messages == null || !_messages.isOpen) {
        _messages = await Hive.openBox('messages');
      } else {
        _messages = Hive.box('messages');
      }
      await _messages.add(messages);
      return true;
    } catch (exc) {
      print("Err in save");
      return false;
    }
  }

  static Future<List<MessageData>> getMessages() async {
    try {
      Box _messages;
      if (_messages == null || !_messages.isOpen) {
        _messages = await Hive.openBox('messages');
      } else {
        _messages = Hive.box('messages');
      }
      List<MessageData> messagesList = [];
      for (int i = 0; i < _messages.length; i++) {
        var msgMap = _messages.getAt(i);
        messagesList.add(msgMap);
      }

      print('messagesLength in getMesages ${messagesList.length}');
      return messagesList;
    } catch (exc) {
      return null;
    }
  }

  static Future<List<MessageData>> getAllUnprocessedMessages() async {
    try {
      Box _messages;
      if (_messages == null || !_messages.isOpen) {
        _messages = await Hive.openBox('messages');
      } else {
        _messages = Hive.box('messages');
      }

      List<MessageData> messagesList = List<MessageData>.from(
          _messages.values.where((item) => item.isProcessed == false));
      print(
          'message length in getAllUnprocessedMessages  ${messagesList.length}');
      return messagesList;
    } catch (exc) {
      return null;
    }
  }

  static Future<bool> removeMessage(String id) async {
    try {
      Box _messages;
      if (_messages == null || !_messages.isOpen) {
        _messages = await Hive.openBox('messages');
      } else {
        _messages = Hive.box('messages');
      }

      List<MessageData> messageList = await getMessages();
      messageList.asMap().forEach((index, value) {
        if (value.messageId == id) {
          _messages.deleteAt(index);
        }
      });
      return true;
    } catch (exc) {
      return null;
    }
  }
}
