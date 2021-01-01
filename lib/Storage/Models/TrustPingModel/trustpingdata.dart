import 'package:hive/hive.dart';

part 'trustpingdata.g.dart';

@HiveType(typeId: 2)
class TrustPingData extends HiveObject {
  @HiveField(0)
  final String connectionId;

  @HiveField(1)
  final String trustPingId;

  @HiveField(2)
  final String trustPingMessage;

  @HiveField(3)
  final String status;

  TrustPingData(
    this.connectionId,
    this.trustPingId,
    this.trustPingMessage,
    this.status,
  );
}
