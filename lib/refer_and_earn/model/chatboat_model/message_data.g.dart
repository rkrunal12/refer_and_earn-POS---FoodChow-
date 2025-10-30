// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageDataAdapter extends TypeAdapter<MessageData> {
  @override
  final int typeId = 1;

  @override
  MessageData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageData(
      title: (fields[0] as List).cast<String>(),
      time: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MessageData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.time);
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
