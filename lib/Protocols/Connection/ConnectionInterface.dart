/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'package:AriesFlutterMobileAgent/Utils/DidDoc.dart';

class Connection {
  String did;
  DidDoc didDoc;
  String verkey;
  String state;
  String theirLabel;
  String theirDid;
  DidDoc theirDidDoc;
  String createdAt;
  String updatedAt;

  // ignore: non_constant_identifier_names
  String get connection_state => state;

  // ignore: non_constant_identifier_names
  set connection_state(String states) {
    this.state = states;
  }

  Connection({
    this.did,
    this.didDoc,
    this.verkey,
    this.state,
    this.theirDid,
    this.theirDidDoc,
    this.theirLabel,
    this.createdAt,
    this.updatedAt,
  });

  Connection.fromJson(Map<String, dynamic> json) {
    did = json['did'];

    theirDid = json['theirDid'];

    if (json['theirDidDoc'] != null) {
      var theirDidDocObj = new DidDoc.fromJson(json['theirDidDoc']);
      theirDidDoc = theirDidDocObj;
    } else {
      theirDidDoc = json['theirDidDoc'];
    }
    verkey = json['verkey'];
    state = json['state'];
    theirLabel = json['theirLabel'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    var didDocObj = new DidDoc.fromJson(json['didDoc']);
    if (json['didDoc'] != null) {
      didDoc = didDocObj;
    } else {
      didDoc = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['did'] = this.did;
    if (this.didDoc != null) {
      data['didDoc'] = this.didDoc.toJson();
    }
    data['theirDid'] = this.theirDid;
    data['theirDidDoc'] = this.theirDidDoc;
    data['verkey'] = this.verkey;
    data['state'] = this.state;
    data['theirLabel'] = this.theirLabel;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
