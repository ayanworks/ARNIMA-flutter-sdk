enum ConnectionStates {
  INIT,
  INVITED,
  REQUESTED,
  RESPONDED,
  COMPLETE,
}

extension ConnectionStateExtension on ConnectionStates {
  String get state {
    switch (this) {
      case ConnectionStates.INIT:
        return "INIT";
      case ConnectionStates.INVITED:
        return "INVITED";
      case ConnectionStates.REQUESTED:
        return "REQUESTED";
      case ConnectionStates.RESPONDED:
        return "RESPONDED";
      case ConnectionStates.COMPLETE:
        return "COMPLETE";
      default:
        return null;
    }
  }
}
