// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'title_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TitleItemAdapter extends TypeAdapter<TitleItem> {
  @override
  final int typeId = 3;

  @override
  TitleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TitleItem(
      message: fields[0] as String,
      replyFromBot: (fields[1] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, TitleItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.message)
      ..writeByte(1)
      ..write(obj.replyFromBot);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TitleItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
