// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messagedata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageDataAdapter extends TypeAdapter<MessageData> {
  @override
  final int typeId = 3;

  @override
  MessageData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageData(
      fields[0] as String,
      fields[1] as String,
      fields[2] as bool,
      fields[4] as bool,
    )..thId = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, MessageData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.messages)
      ..writeByte(2)
      ..write(obj.auto)
      ..writeByte(3)
      ..write(obj.thId)
      ..writeByte(4)
      ..write(obj.isProcessed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
