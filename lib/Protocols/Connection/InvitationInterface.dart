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
