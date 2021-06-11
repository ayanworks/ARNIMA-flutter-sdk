/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walletdata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletDataAdapter extends TypeAdapter<WalletData> {
  @override
  final int typeId = 0;

  @override
  WalletData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletData(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WalletData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.walletConfig)
      ..writeByte(1)
      ..write(obj.walletCredentials)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.publicDid)
      ..writeByte(4)
      ..write(obj.verkey)
      ..writeByte(5)
      ..write(obj.masterSecretId)
      ..writeByte(6)
      ..write(obj.serviceEndpoint)
      ..writeByte(7)
      ..write(obj.routingKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
