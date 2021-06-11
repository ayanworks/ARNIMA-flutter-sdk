/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'package:AriesFlutterMobileAgent/Utils/Helpers.dart';
import 'package:uuid/uuid.dart';
import 'package:AriesFlutterMobileAgent/Utils/MessageType.dart';

Object presentationProposalMessage(
  // ignore: non_constant_identifier_names
  Object presentation_proposal,
  String comment,
) {
  return {
    '@type': MessageType.ProposePresentation,
    '@id': Uuid().v4(),
    'comment': comment,
    'presentation_proposal': presentation_proposal,
  };
}

Object createPresentationMessage(
    dynamic data, String comment, String threadId) {
  return {
    '@type': MessageType.Presentation,
    '@id': Uuid().v4(),
    '~thread': {
      'thid': threadId,
    },
    'comment': comment,
    'presentations~attach': [
      {
        '@id': 'libindy-presentation-0',
        'mime-type': 'application/json',
        'data': {
          'base64': encodeBase64(
            data,
          )
        }
      },
    ]
  };
}
