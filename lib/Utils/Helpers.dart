import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionInterface.dart';
import 'package:AriesFlutterMobileAgent/Protocols/Connection/ConnectionMessages.dart';
import 'package:AriesFlutterMobileAgent/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const MethodChannel channel = const MethodChannel('AriesFlutterMobileAgent');

enum RecordType {
  Connection,
  TrustPing,
  BasicMessage,
  Credential,
  Presentation,
  MediatorAgent,
  SSIMessage,
}

String encodeInvitationFromObject(
  Object invitation,
  String serviceEndpoint,
) {
  String result = jsonEncode(invitation);
  List<int> bytes = utf8.encode(result);
  String encodedInvitation = base64.encode(bytes);
  String encodedUrl = serviceEndpoint + '?c_i=' + encodedInvitation;
  print('encodedUrl $encodedUrl');
  return encodedUrl;
}

Object decodeInvitationFromUrl(String invitationUrl) {
  final List<String> encodedInvitation = invitationUrl.split('c_i=');
  final List<int> res = base64.decode(encodedInvitation[1]);
  final invitation = utf8.decode(res);
  return invitation;
}

Object createOutboundMessage(
  Connection connection,
  Object payload, [
  invitation,
]) {
  if (invitation != null) {
    var data = {
      'connection': jsonEncode(connection),
      "endpoint": invitation['serviceEndpoint'],
      "payload": jsonDecode(payload),
      "recipientKeys": invitation['recipientKeys'],
      "routingKeys": invitation.toString().contains('routingKeys')
          ? invitation['routingKeys']
          : [],
      "senderVk": connection.verkey,
    };
    return jsonEncode(data);
  }

  DidDoc theirDidDoc = connection.theirDidDoc;

  if (theirDidDoc.toString() == '') {
    throw ErrorDescription('In createOutboundMessage DidDoc is Empty');
  }

  var objValues = {
    'connection': jsonEncode(connection),
    'endpoint': theirDidDoc.service[0].serviceEndpoint,
    'payload': jsonDecode(payload),
    'recipientKeys': theirDidDoc.service[0].recipientKeys,
    'routingKeys': theirDidDoc.service[0].routingKeys,
    'senderVk': connection.verkey,
  };

  return jsonEncode(objValues);
}

dynamic unPackMessage(
  String configJson,
  String credentialsJson,
  payload,
) async {
  try {
    var unPackMessage;
    if (Platform.isIOS) {
      unPackMessage =
          await channel.invokeMethod('unpackMessage', <String, dynamic>{
        'configJson': configJson,
        'credentialJson': credentialsJson,
        'payload': jsonEncode(payload),
      });
      return unPackMessage;
    } else {
      Uint8List bytes = utf8.encode(jsonEncode(payload));
      unPackMessage =
          await channel.invokeMethod('unpackMessage', <String, dynamic>{
        'configJson': configJson,
        'credentialJson': credentialsJson,
        'payload': bytes,
      });
      var inboundPackedMessage = utf8.decode(unPackMessage?.cast<int>());
      return inboundPackedMessage;
    }
  } catch (error) {
    print('Error In UnPAckMessage Helper.dart:$error');
  }
}

dynamic packMessage(
  String configJson,
  String credentialsJson,
  outboundMessage,
) async {
  try {
    var packedBufferMessage;
    var message;
    var value = jsonDecode(outboundMessage);

    if (Platform.isIOS) {
      packedBufferMessage =
          await channel.invokeMethod('packMessage', <String, dynamic>{
        'configJson': configJson,
        'credentialsJson': credentialsJson,
        'payload': jsonEncode(value['payload']),
        'recipientKeys': value['recipientKeys'],
        'senderVk': value['senderVk'],
      });
      message = packedBufferMessage;
    } else {
      Uint8List bytes = utf8.encode(jsonEncode(value['payload']));
      packedBufferMessage =
          await channel.invokeMethod('packMessage', <String, dynamic>{
        'configJson': configJson,
        'credentialJson': credentialsJson,
        'payload': bytes,
        'recipientKeys': value['recipientKeys'],
        'senderVk': value['senderVk'],
      });
      var outboundPackedMessage = utf8.decode(packedBufferMessage?.cast<int>());
      message = outboundPackedMessage;
    }

    var forwardBufferMessage;

    if (value['routingKeys'].isNotEmpty && value['routingKeys'].length > 0) {
      print('\n\n\n\n PA-Ck....');

      print('value.routingKeys:${value['routingKeys']}');

      for (var routingKey in value['routingKeys']) {
        print('In For loop');

        print('In For loop:routingKey ::$routingKey ');

        dynamic recipientKey = jsonDecode(outboundMessage)['recipientKeys'];
        print('In For loop:recipientKey ::$recipientKey ');
        print('In For loop:recipientKey type ::${recipientKey.runtimeType} ');

        Object forwardMessage = createForwardMessage(recipientKey[0], message);
        List<int> forwardMessageBuffer =
            utf8.encode(jsonEncode(forwardMessage));
        if (Platform.isIOS) {
          print("In for loop:iOS:packMessage");
          forwardBufferMessage =
              await channel.invokeMethod('packMessage', <String, dynamic>{
            'configJson': configJson,
            'credentialJson': credentialsJson,
            'payload': forwardMessage,
            'recipientKeys': [routingKey],
            'senderVk': value['senderVk'],
          });
          return message = forwardBufferMessage;
        } else {
          print("In for loop:Android:packMessage");
          print("forwardMessageBuffer ${forwardMessageBuffer.runtimeType}");
          print("routingKey ${routingKey.runtimeType}");
          print("outboundMessage['senderVk'] $value");

          forwardBufferMessage =
              await channel.invokeMethod('packMessage', <String, dynamic>{
            'configJson': configJson,
            'credentialJson': credentialsJson,
            'payload': forwardMessageBuffer,
            'recipientKeys': [routingKey],
            'senderVk': value['senderVk'],
          });
          var message = utf8.decode(packedBufferMessage?.cast<int>());
          return message;
        }
      }
    } else {
      print("In else packMessage");
      print(message);
      return message;
    }
  } catch (err) {
    print("Error in pack message $err");
    throw err;
  }
}

Future verify(
  String configJson,
  String credentialsJson,
  Message message,
  String field,
) async {
  print('Message::: ${message.data}');

  Map<String, dynamic> data = jsonDecode(message.data);

  var signerVerkey = data['signer'];
  var signedData = base64Decode(data['sig_data']);
  var signature = base64Decode(data['signature']);

  bool isValid;

  if (Platform.isIOS) {
    print('Verify Method in ConnectionService in iOS');
    isValid = await channel.invokeMethod('cryptoVerify', <String, dynamic>{
      'configJson': configJson,
      'credentialJson': credentialsJson,
      'signVerkeyJson': signerVerkey,
      'messageJson': signedData,
      'signatureRawJson': signature
    });
  } else {
    print('Verify Method in ConnectionService in android');
    isValid = await channel.invokeMethod('cryptoVerify', <String, dynamic>{
      'configJson': configJson,
      'credentialJson': credentialsJson,
      'signVerkey': signerVerkey,
      'messageRaw': signedData,
      'signatureRaw': signature
    });
  }

  String connectionInOriginalMessage =
      new String.fromCharCodes(signedData.sublist(8, signedData.length));

  if (isValid) {
    var originalMessage = {
      '@type': message.type,
      '@id': message.id,
      '$field': connectionInOriginalMessage,
    };
    print('isValid in verify : ConnectionService :$isValid');
    return originalMessage;
  } else {
    throw ErrorDescription('Signature is not valid!');
  }
}

Uint8List timestamp() {
  var time = DateTime.now().millisecondsSinceEpoch;
  List<int> bytes = [];
  for (var i = 0; i < 8; i++) {
    var byte = time & 0xff;
    bytes.add(byte);
    time = ((time - byte) / 256) as int;
  }
  return Uint8List.fromList(bytes.reversed.toList());
}

dynamic sign(
  String configJson,
  String credentialsJson,
  String signerVerkey,
  message,
  field,
) async {
  try {
    Uint8List dataBuffer =
        timestamp() + utf8.encode(jsonEncode(message['$field']));
    var signatureBuffer;
    if (Platform.isIOS) {
      signatureBuffer =
          await channel.invokeMethod('cryptoSign', <String, dynamic>{
        'configJson': configJson,
        'credentialJson': credentialsJson,
        'signerVerkey': signerVerkey,
        'messageRaw': jsonEncode(message['$field']),
      });
    } else {
      signatureBuffer =
          await channel.invokeMethod('cryptoSign', <String, dynamic>{
        'configJson': configJson,
        'credentialJson': credentialsJson,
        'signerVerkey': signerVerkey,
        'messageRaw': dataBuffer,
      });
    }

    message.remove(field);

    var signedMessage = {
      '@type': message['@type'],
      '@id': message['@id'],
      ...message,
      ['$field~sig']: {
        '@type':
            'did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/signature/1.0/ed25519Sha512_single',
        'signature': base64Encode(signatureBuffer),
        'sig_data': base64Encode(dataBuffer),
        'signer': signerVerkey,
      }
    };
    return signedMessage;
  } catch (err) {
    print("Error in pack message $err");
    throw err;
  }
}
