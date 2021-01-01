import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionInterface.dart';
import 'package:flutter/material.dart';

class InboundMessage {
  final String senderVerkey;
  final String recipientVerkey;
  final dynamic message;

  InboundMessage(this.senderVerkey, this.recipientVerkey, this.message);
}

class Message {
  String id = '@id';
  String type = '@type';
  String data;

  Message(this.id, this.type, this.data);
}

class OutboundMessage {
  final Connection connection;
  final Object payload;
  final List<String> recipientKeys;
  final List<String> routingKeys;
  final String senderVk;
  final String endpoint;

  OutboundMessage({
    @required this.connection,
    @required this.payload,
    @required this.recipientKeys,
    @required this.routingKeys,
    @required this.senderVk,
    this.endpoint,
  });
}
