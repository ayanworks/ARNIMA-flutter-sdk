/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'package:hive/hive.dart';

part 'walletdata.g.dart';

@HiveType(typeId: 0)
class WalletData extends HiveObject {
  @HiveField(0)
  final String walletConfig;

  @HiveField(1)
  final String walletCredentials;

  @HiveField(2)
  final String label;

  @HiveField(3)
  final String publicDid;

  @HiveField(4)
  final String verkey;

  @HiveField(5)
  final String masterSecretId;

  @HiveField(6)
  final String serviceEndpoint;

  @HiveField(7)
  final String routingKey;

  WalletData(
    this.walletConfig,
    this.walletCredentials,
    this.label,
    this.publicDid,
    this.verkey,
    this.masterSecretId,
    this.serviceEndpoint,
    this.routingKey,
  );

  WalletData.next(
      {this.walletConfig,
      this.walletCredentials,
      this.label,
      this.publicDid,
      this.verkey,
      this.masterSecretId,
      this.serviceEndpoint,
      this.routingKey});
}
