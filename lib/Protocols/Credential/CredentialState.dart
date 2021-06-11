/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
enum CredentialState {
  STATE_REQUEST_SENT,
  STATE_REQUEST_RECEIVED,
  STATE_ISSUED,
  STATE_CREDENTIAL_RECEIVED,
  STATE_ACKED,
  STATE_REVOKED
}

extension CredentialStateExtension on CredentialState {
  String get state {
    switch (this) {
      case CredentialState.STATE_REQUEST_SENT:
        return "STATE_REQUEST_SENT";
      case CredentialState.STATE_REQUEST_RECEIVED:
        return "STATE_REQUEST_RECEIVED";
      case CredentialState.STATE_ISSUED:
        return "STATE_ISSUED";
      case CredentialState.STATE_CREDENTIAL_RECEIVED:
        return "STATE_CREDENTIAL_RECEIVED";
      case CredentialState.STATE_ACKED:
        return "STATE_ACKED";
      case CredentialState.STATE_REVOKED:
        return "STATE_REVOKED";

      default:
        return null;
    }
  }
}
