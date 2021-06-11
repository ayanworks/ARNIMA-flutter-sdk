/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'package:hive/hive.dart';

part 'credentialdata.g.dart';

@HiveType(typeId: 4)
class CredentialData extends HiveObject {
  @HiveField(0)
  final String issuecredentialId;

  @HiveField(1)
  final String credentialId;

  @HiveField(2)
  final String connectionId;

  @HiveField(3)
  final String issuecredential;

  CredentialData({
    this.issuecredentialId,
    this.credentialId,
    this.connectionId,
    this.issuecredential,
  });
}
