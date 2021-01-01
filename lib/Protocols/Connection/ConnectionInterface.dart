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
    theirDidDoc = json['theirDidDoc'];
    didDoc =
        json['didDoc'] != null ? new DidDoc.fromJson(json['didDoc']) : null;
    verkey = json['verkey'];
    state = json['state'];
    theirLabel = json['theirLabel'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['did'] = this.did;
    if (this.didDoc != null) {
      data['didDoc'] = this.didDoc.toJson();
    }
    if (this.theirDidDoc != null) {
      data['theirDidDoc'] = this.theirDidDoc.toJson();
    }
    if (this.theirDid != null) {
      data['theirDid'] = this.theirDid;
    }
    data['verkey'] = this.verkey;
    data['state'] = this.state;
    data['theirLabel'] = this.theirLabel;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
