/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'dart:convert';

import 'package:AriesFlutterMobileAgent/Utils/MessageType.dart';
import 'package:uuid/uuid.dart';

String createTrustPingMessage({
  bool responseRequested = true,
  String comment = '',
}) {
  Map<String, dynamic> trustedMessage = {
    '@id': Uuid().v4(),
    '@type': MessageType.TrustPingMessage,
    'comment': comment,
    'responseRequested': responseRequested
  };

  return jsonEncode(trustedMessage);
}

dynamic createTrustPingResponseMessage(
  String threadId, {
  String comment = "",
}) {
  return {
    '@id': Uuid().v4(),
    '@type': MessageType.TrustPingResponseMessage,
    '~thread': {
      'thid': threadId,
    },
    'comment': comment,
  };
}
