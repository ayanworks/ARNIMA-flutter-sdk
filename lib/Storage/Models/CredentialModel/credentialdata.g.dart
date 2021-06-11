/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentialdata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialDataAdapter extends TypeAdapter<CredentialData> {
  @override
  final int typeId = 4;

  @override
  CredentialData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CredentialData(
      issuecredentialId: fields[0] as String,
      credentialId: fields[1] as String,
      connectionId: fields[2] as String,
      issuecredential: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CredentialData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.issuecredentialId)
      ..writeByte(1)
      ..write(obj.credentialId)
      ..writeByte(2)
      ..write(obj.connectionId)
      ..writeByte(3)
      ..write(obj.issuecredential);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
