/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
class Presentation {
  String connectionId;
  String theirLabel;
  String threadId;
  String presentationRequest;
  String presentation;
  String state;
  String createdAt;
  String updatedAt;

  Presentation({
    this.connectionId,
    this.theirLabel,
    this.threadId,
    this.presentationRequest,
    this.presentation,
    this.state,
    this.createdAt,
    this.updatedAt,
  });

  Presentation.fromJson(Map<String, dynamic> json) {
    connectionId = json['connectionId'];
    theirLabel = json['theirLabel'];
    threadId = json['threadId'];
    presentationRequest = json['presentationRequest'];
    presentation = json['presentation'];
    state = json['state'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['connectionId'] = this.connectionId;
    data['theirLabel'] = this.theirLabel;
    data['threadId'] = this.threadId;
    data['presentationRequest'] = this.presentationRequest;
    data['presentation'] = this.presentation;
    data['state'] = this.state;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
