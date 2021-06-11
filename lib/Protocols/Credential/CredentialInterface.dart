/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
class Credential {
  String connectionId;
  String threadId;
  String theirLabel;
  String credentialDefinitionId;
  String revocRegId;
  String schemaId;
  String credentialOffer;
  String credDefJson;
  String revocRegDefJson;
  String credentialRequest;
  String credentialRequestMetadata;
  String credentialId;
  String rawCredential;
  String credential;
  String state;
  String createdAt;
  String updatedAt;

  Credential({
    this.connectionId,
    this.state,
    this.credentialDefinitionId,
    this.threadId,
    this.theirLabel,
    this.revocRegId,
    this.schemaId,
    this.credentialOffer,
    this.credDefJson,
    this.revocRegDefJson,
    this.credentialRequest,
    this.credentialRequestMetadata,
    this.credentialId,
    this.rawCredential,
    this.credential,
    this.createdAt,
    this.updatedAt,
  });

  Credential.fromJson(Map<String, dynamic> json) {
    connectionId = json['connectionId'];
    credentialId = json['credentialId'];
    threadId = json['threadId'];
    theirLabel = json['theirLabel'];
    credentialDefinitionId = json['credentialDefinitionId'];
    revocRegId = json['revocRegId'];
    schemaId = json['schemaId'];
    credentialOffer = json['credentialOffer'];
    credDefJson = json['credDefJson'];
    revocRegDefJson = json['revocRegDefJson'];
    credentialRequest = json['credentialRequest'];
    credentialRequestMetadata = json['credentialRequestMetadata'];
    rawCredential = json['rawCredential'];
    credential = json['credential'];
    state = json['state'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['connectionId'] = this.connectionId;
    data['credentialId'] = this.credentialId;
    data['threadId'] = this.threadId;
    data['theirLabel'] = this.theirLabel;
    data['credentialDefinitionId'] = this.credentialDefinitionId;
    data['revocRegId'] = this.revocRegId;
    data['schemaId'] = this.schemaId;
    data['credentialOffer'] = this.credentialOffer;
    data['credDefJson'] = this.credDefJson;
    data['credentialRequest'] = this.credentialRequest;
    data['credentialRequestMetadata'] = this.credentialRequestMetadata;
    data['rawCredential'] = this.rawCredential;
    data['credential'] = this.credential;
    data['state'] = this.state;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
