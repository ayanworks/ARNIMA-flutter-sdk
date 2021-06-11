/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
class InvitationDetails {
  String label;
  List<String> recipientKeys;
  String serviceEndpoint;
  List<String> routingKeys;

  InvitationDetails({
    this.label,
    this.recipientKeys,
    this.serviceEndpoint,
    this.routingKeys,
  });
}
