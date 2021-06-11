/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
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
    } catch (exception) {
      throw exception;
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
    } catch (exception) {
      throw exception;
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
    } catch (exception) {
      throw exception;
    }
  }

  static Future<String> getServiceEndpoint() async {
    try {
      var walletData = await getWalletData();
      String serviceEndpoint =
          walletData.serviceEndpoint.replaceFirst('/endpoint', '');
      return serviceEndpoint;
    } catch (exception) {
      throw exception;
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
      await _connections.add(connections);
      return true;
    } catch (exception) {
      throw exception;
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
    } catch (exception) {
      throw exception;
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
    } catch (exception) {
      throw exception;
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
    } catch (exception) {
      throw exception;
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
      List<MessageData> messageList = await getMessages();
      for (int i = 0; i < messageList.length; i++) {
        if (messageList[i].messageId == messages.messageId) {
          _messages.putAt(i, messages);
          return true;
        }
      }
      await _messages.add(messages);
      return true;
    } catch (exception) {
      throw exception;
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
      return messagesList;
    } catch (exception) {
      throw exception;
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
      return messagesList;
    } catch (exception) {
      throw exception;
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
    } catch (exception) {
      throw exception;
    }
  }

  static Future<List<CredentialData>> getAllCredentials() async {
    try {
      Box _credentials;
      if (_credentials == null || !_credentials.isOpen) {
        _credentials = await Hive.openBox('credentials');
      } else {
        _credentials = Hive.box('credentials');
      }
      List<CredentialData> credentials = [];
      for (int i = 0; i < _credentials.length; i++) {
        var connectionMap = _credentials.getAt(i);
        credentials.add(connectionMap);
      }
      return credentials;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<CredentialData> getissuecredential(
      String issuecredentialId) async {
    try {
      Box _credentials;
      if (_credentials == null || !_credentials.isOpen) {
        _credentials = await Hive.openBox('credentials');
      } else {
        _credentials = Hive.box('credentials');
      }

      CredentialData credentialRecord = new List<CredentialData>.from(
              _credentials.values.toList())
          .where((element) => element.issuecredentialId == issuecredentialId)
          .last;

      return credentialRecord;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<bool> storeIssuecredential(CredentialData credential) async {
    try {
      Box _credentials;
      if (_credentials == null || !_credentials.isOpen) {
        _credentials = await Hive.openBox('credentials');
      } else {
        _credentials = Hive.box('credentials');
      }

      List<CredentialData> credentials = await getAllCredentials();
      for (int i = 0; i < credentials.length; i++) {
        var existingValue = credentials[i];
        if (existingValue.issuecredentialId == credential.issuecredentialId) {
          _credentials.putAt(i, credential);
          return true;
        }
      }
      await _credentials.add(credential);
      return true;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<List<CredentialData>> getIssueCredentialByConnectionId(
      connectionId) async {
    try {
      Box _credentials;
      if (_credentials == null || !_credentials.isOpen) {
        _credentials = await Hive.openBox('credentials');
      } else {
        _credentials = Hive.box('credentials');
      }

      List<CredentialData> credentials = List<CredentialData>.from(
        _credentials.values.where(
          (item) => item.connectionId == connectionId,
        ),
      );
      return credentials;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<String> getMasterSecretId() async {
    WalletData userData = await getUserData();
    return userData.masterSecretId;
  }

  static Future<WalletData> getUserData() async {
    try {
      Box<WalletData> _wallet;
      if (_wallet == null || !_wallet.isOpen) {
        _wallet = await Hive.openBox('wallet');
      } else {
        _wallet = Hive.box('wallet');
      }
      WalletData userData = _wallet.get(0);
      return userData;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<MessageData> getActionMessagesById(String thId) async {
    try {
      Box _messages;
      if (_messages == null || !_messages.isOpen) {
        _messages = await Hive.openBox('messages');
      } else {
        _messages = Hive.box('messages');
      }
      List<MessageData> data = [];
      List<MessageData> messageList = await getMessages();
      messageList.asMap().forEach(
        (index, value) {
          if (value.thId == thId) {
            data.add(value);
          }
        },
      );
      return data[0];
    } catch (exception) {
      throw exception;
    }
  }

  static Future<List<MessageData>> getAllActionMessagesByConnectionId(
      String connectionId) async {
    try {
      Box _messages;
      if (_messages == null || !_messages.isOpen) {
        _messages = await Hive.openBox('messages');
      } else {
        _messages = Hive.box('messages');
      }

      List<MessageData> data = [];

      List<MessageData> messageList = await getMessages();
      messageList.asMap().forEach(
        (index, value) {
          if (value.connectionId == connectionId) {
            data.add(value);
          }
        },
      );
      return data;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<List<MessageData>> getAllActionMessages() async {
    try {
      Box _messages;
      if (_messages == null || !_messages.isOpen) {
        _messages = await Hive.openBox('messages');
      } else {
        _messages = Hive.box('messages');
      }

      List<MessageData> data = [];

      List<MessageData> messageList = await getMessages();
      messageList.asMap().forEach((index, value) {
        if (value.auto == false) {
          data.add(value);
        }
      });
      return data;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<List<PresentationData>> getAllPresentations() async {
    try {
      Box _presentation;
      if (_presentation == null || !_presentation.isOpen) {
        _presentation = await Hive.openBox('presentation');
      } else {
        _presentation = Hive.box('presentation');
      }
      List<PresentationData> presentationList = [];
      for (int i = 0; i < _presentation.length; i++) {
        var map = _presentation.getAt(i);
        presentationList.add(map);
      }
      return presentationList;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<bool> storePresentation(
      PresentationData presentationData) async {
    try {
      Box _presentation;
      if (_presentation == null || !_presentation.isOpen) {
        _presentation = await Hive.openBox('presentation');
      } else {
        _presentation = Hive.box('presentation');
      }

      List<PresentationData> presentationList = await getAllPresentations();
      for (int i = 0; i < presentationList.length; i++) {
        if (presentationList[i].presentationId ==
            presentationData.presentationId) {
          _presentation.putAt(i, presentationData);
          return true;
        }
      }

      await _presentation.add(presentationData);
      return true;
    } catch (exception) {
      throw exception;
    }
  }

  static Future<List<PresentationData>> getPresentationByConnectionId(
      String connectionId) async {
    try {
      Box _presentation;
      if (_presentation == null || !_presentation.isOpen) {
        _presentation = await Hive.openBox('presentation');
      } else {
        _presentation = Hive.box('presentation');
      }

      List<PresentationData> presentationList = List<PresentationData>.from(
        _presentation.values.where(
          (item) => item.connectionId == connectionId,
        ),
      );

      return presentationList;
    } catch (exception) {
      throw exception;
    }
  }
}
