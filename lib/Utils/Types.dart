import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionInterface.dart';
import 'package:flutter/material.dart';

class InboundMessage {
  String senderVerkey;
  String recipientVerkey;
  dynamic message;

  InboundMessage({this.senderVerkey, this.recipientVerkey, this.message});

  InboundMessage.fromJson(Map<String, dynamic> json) {
    senderVerkey = json['sender_verkey'];
    recipientVerkey = json['recipient_verkey'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sender_verkey'] = this.senderVerkey;
    data['recipient_verkey'] = this.recipientVerkey;
    data['message'] = this.message;
    return data;
  }
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
