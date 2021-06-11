/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'package:AriesFlutterMobileAgent/Utils/Helpers.dart';
import 'package:AriesFlutterMobileAgent/Utils/MessageType.dart';
import 'package:uuid/uuid.dart';

credentialPreviewMessage(attributes) {
  return {
    '@type': MessageType.CredentialPreview,
    'attributes': attributes,
  };
}

credentialProposalMessage(
  String credentialProposal,
  String schemaId,
  String credDefId,
  String issuerDid,
) {
  var schema = schemaId.split(':');
  return {
    '@type': MessageType.ProposeCredential,
    '@id': Uuid().v4(),
    'comment': '',
    'credential_proposal': credentialProposal,
    'schema_issuer_did': schema[0],
    'schema_id': schemaId,
    'schema_name': schema[2],
    'schema_version': schema[3],
    'cred_def_id': credDefId,
    'issuer_did': issuerDid,
  };
}

createRequestCredentialMessage(
    String data, String comment, String threadId) async {
  return {
    '@type': MessageType.RequestCredential,
    '@id': Uuid().v4(),
    '~thread': {
      'thid': threadId,
    },
    'comment': comment,
    'requests~attach': [
      {
        '@id': Uuid().v4(),
        'mime-type': 'application/json',
        'data': {'base64': await encodeBase64(data)}
      },
    ]
  };
}

storedCredentialAckMessage(String threadId) {
  return {
    '@type': MessageType.CredentialAck,
    '@id': Uuid().v4(),
    "status": "OK",
    '~thread': {
      'thid': threadId,
    }
  };
}
