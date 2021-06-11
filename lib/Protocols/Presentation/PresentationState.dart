/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
enum PresentationState {
  STATE_REQUEST_SENT,
  STATE_REQUEST_RECEIVED,
  STATE_PRESENTATION_SENT,
  STATE_PRESENTATION_RECEIVED,
  STATE_VERIFIED,
  STATE_PRESENTATION_ACKED,
  STATE_PROPOSAL_SENT
}

extension PresentationStateExtension on PresentationState {
  String get state {
    switch (this) {
      case PresentationState.STATE_REQUEST_SENT:
        return "STATE_REQUEST_SENT";
      case PresentationState.STATE_REQUEST_RECEIVED:
        return "STATE_REQUEST_RECEIVED";
      case PresentationState.STATE_PRESENTATION_SENT:
        return "STATE_PRESENTATION_SENT";
      case PresentationState.STATE_PRESENTATION_RECEIVED:
        return "STATE_PRESENTATION_RECEIVED";
      case PresentationState.STATE_VERIFIED:
        return "STATE_VERIFIED";
      case PresentationState.STATE_PRESENTATION_ACKED:
        return "STATE_PRESENTATION_ACKED";
      case PresentationState.STATE_PROPOSAL_SENT:
        return "STATE_PROPOSAL_SENT";
      default:
        return null;
    }
  }
}
