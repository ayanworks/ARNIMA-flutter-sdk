/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'package:flutter/material.dart';

class WalletConfig {
  final String id;
  final List<String> storageType;
  final StorageConfig storageConfig;

  WalletConfig({
    @required this.id,
    this.storageType,
    this.storageConfig,
  });
}

class WalletCredentials {
  String key;
  WalletCredentials({@required this.key});
}

class DidJson {
  final String did;
  final String seed;
  final String methodName;

  DidJson({
    this.did,
    this.seed,
    this.methodName,
  });
}

class StorageConfig {
  String path;
  StorageConfig({this.path});
}
