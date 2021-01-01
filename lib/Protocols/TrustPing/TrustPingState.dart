enum TrustPingState { SENT, ACTIVE }

extension TrustPingStateExtension on TrustPingState {
  String get state {
    switch (this) {
      case TrustPingState.SENT:
        return "SENT";
      case TrustPingState.ACTIVE:
        return "ACTIVE";
      default:
        return null;
    }
  }
}
