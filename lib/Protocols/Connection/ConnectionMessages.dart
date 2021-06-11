/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'dart:convert';

import 'package:AriesFlutterMobileAgent/Utils/utils.dart';
import 'package:uuid/uuid.dart';

import 'ConnectionInterface.dart';

var uuid = Uuid();

Object createInvitationMessage(
  Connection connection,
  String label,
) {
  DidDoc didDoc = connection.didDoc;
  var data = {
    '@type': MessageType.ConnectionInvitation,
    '@id': uuid.v4(),
    'label': label,
    'recipientKeys': didDoc.service[0].recipientKeys,
    'serviceEndpoint': didDoc.service[0].serviceEndpoint,
    'routingKeys': didDoc.service[0].routingKeys,
  };
  return data;
}

Object createConnectionRequestMessage(
  Connection connection,
  String label,
) {
  var data = {
    '@type': MessageType.ConnectionRequest,
    '@id': uuid.v4(),
    'label': label,
    'connection': {
      'DID': connection.did,
      'DIDDoc': connection.didDoc,
    },
  };
  return jsonEncode(data);
}

Object createConnectionResponseMessage(
  Connection connection,
  String thid,
) {
  return {
    '@type': MessageType.ConnectionResponse,
    '@id': uuid.v4(),
    '~thread': {
      thid,
    },
    'connection': {
      'DID': connection.did,
      'DIDDoc': connection.didDoc,
    },
  };
}

Object createAckMessage(String threadId) {
  return {
    '@type': MessageType.Ack,
    '@id': uuid.v4(),
    'status': 'OK',
    '~thread': {
      'thid': threadId,
    },
  };
}

Object createForwardMessage(
  String to,
  dynamic msg,
) {
  final forwardMessage = {
    '@type': MessageType.ForwardMessage,
    'to': to,
    'msg': msg,
  };
  return forwardMessage;
}
